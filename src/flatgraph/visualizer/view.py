import logging
from pathlib import Path

import os
from .base import Visualizer
from nicegui import events, ui

from flatland.envs.rail_env import RailEnv
from flatland.envs.rail_generators import sparse_rail_generator, rail_from_grid_transition_map
from flatland.envs.line_generators import sparse_line_generator
from flatland.envs.observations import GlobalObsForRailEnv

from flatland.core.transition_map import GridTransitionMap

from flatland.envs.rail_env import RailEnv

import PIL
from flatland.utils.rendertools import RenderTool
import numpy as np
import subprocess
import json
import re
import random

ENCODING = "encodings/order_test.lp"
ENCODING_CONNECTIONS = "encodings/back_connections.lp"

ENCODING_FULL = "encodings/rail_new_actions.lp"

TEMP_FOLDER = "visualizer_files"
INSTANCE_ASP = f"{TEMP_FOLDER}/instance.lp"
INSTANCE_PNG = f"{TEMP_FOLDER}/instance.png"
JSON_OUTPUT = f"{TEMP_FOLDER}/output.json"

DIRECTION_MAP = {
    'n': 0, 
    'e': 1, 
    's': 2, 
    'w': 3
}

REVERSE_DIRECTION_MAP = {
    0: "n",
    1: "e",
    2: "s",
    3: "w"
}

class DefaultLine:
    def __init__(self, agent_positions, agent_targets, agent_directions, agent_speeds):
        self.agent_positions = agent_positions
        self.agent_targets = agent_targets
        self.agent_directions = agent_directions
        self.agent_speeds = agent_speeds


def default_line_generator(rail, num_agents, hints, *args, **kwargs):
    if hints is None:
        hints = {}
    hints['train_stations'] = []

    agent_positions = [None] * num_agents
    agent_targets = [None] * num_agents
    agent_directions = [None] * num_agents
    agent_speeds = [1.0] * num_agents
    return DefaultLine(agent_positions, agent_targets, agent_directions, agent_speeds)


class DefaultObservationBuilder:
    def set_env(self, env):
        pass

    def reset(self, env=None): 
        pass

    def get(self, handle=0):
        return None

    def get_many(self, handles=None):
        if handles is None:
            handles = []
        return {h: None for h in handles}


class VisualizerView(Visualizer):

    def __init__(self):
        super().__init__()


    def visualize(self, instance_path, timed, provided_instance=''):
        print("Generate Visual")

        Path(TEMP_FOLDER).mkdir(parents=True, exist_ok=True)
        
        self.seed = 100
        random.seed(self.seed)

        if provided_instance == '':
            random_env = self.generate_random_rail()
        else:
            random_env = self.generate_provided_rail(provided_instance)

        env_image = self.render_env(random_env)

        run_encoding = self.env_encoding(random_env)
        if run_encoding:
            self.run_encoding()

        positions_dict = self.get_final_positions()
        self.create_ui(env_image, positions_dict)


    def get_tracks_agents(self, provided_instance):

        tracks_dict = {}
        agent_dict = {}
        max_x_y = 0
        max_agent_id = 0

        with open(provided_instance, "r") as output:
            text = output.read()

            LEFT_PAREN = r"\s*\(\s*"
            RIGHT_PAREN = r"\s*\)\s*"
            COMMA = r"\s*,\s*"

            # Example: start(0,(5,15),4,s).
            match_string = (r"start" f"{LEFT_PAREN}" r"(?P<agent_id>\d+)" f"{COMMA}" 
                            f"{LEFT_PAREN}" r"(?P<y>\d+)" f"{COMMA}" r"(?P<x>\d+)" f"{RIGHT_PAREN}"
                            f"{COMMA}" r"(?P<time>\d+)" f"{COMMA}" r"(?P<dir>\w+)" f"{RIGHT_PAREN}" r"\.") 

            match_pat = re.compile(match_string)
            find_match = match_pat.finditer(text)

            for match in find_match:
                matched = match.groupdict()
                agent_id = int(matched["agent_id"])
                agent_dict[agent_id] = agent_dict.get(agent_id, {})
                max_agent_id = max(max_agent_id, agent_id)

                agent = agent_dict[agent_id]
                agent["initial_position"] = (int(matched['y']), int(matched['x']))
                agent["initial_direction"] = DIRECTION_MAP[matched['dir']]
                agent["earliest_departure"] = int(matched['time'])

            # Example: end(0,(5,15),4).
            match_string = (r"end" f"{LEFT_PAREN}" r"(?P<agent_id>\d+)" f"{COMMA}" 
                            f"{LEFT_PAREN}" r"(?P<y>\d+)" f"{COMMA}" r"(?P<x>\d+)" f"{RIGHT_PAREN}"
                            f"{COMMA}" r"(?P<time>\d+)" f"{RIGHT_PAREN}" r"\.")

            match_pat = re.compile(match_string)
            find_match = match_pat.finditer(text)

            for match in find_match:
                matched = match.groupdict()
                agent_id = int(matched["agent_id"])
                
                agent = agent_dict[agent_id]
                agent["target"] = (int(matched['y']), int(matched['x']))
                agent["latest_arrival"] = int(matched['time'])

            # Example: cell((1, 0), 1025).
            match_string = (r"cell" f"{LEFT_PAREN}"
                            f"{LEFT_PAREN}" r"(?P<y>\d+)" f"{COMMA}" r"(?P<x>\d+)" f"{RIGHT_PAREN}"
                            f"{COMMA}" r"(?P<track>\d+)" f"{RIGHT_PAREN}" r"\.")

            match_pat = re.compile(match_string)
            find_match = match_pat.finditer(text)

            for match in find_match:
                matched = match.groupdict()
                cell_x = int(matched["x"])
                cell_y = int(matched["y"])
                cell = (cell_x, cell_y)
                cell_track = int(matched["track"])

                max_x_y = max(max_x_y, cell_x, cell_y)

                if cell_track != 0:
                    tracks_dict[cell] = cell_track

            logging.info(agent_dict)
            logging.info(tracks_dict)

        # Example: [[0, 0, 0], [1025, 1025, 1025], [0, 0, 0]]
        tracks = []

        for y in range(max_x_y+1):
            track_row = []
            tracks.append(track_row)
            for x in range(max_x_y+1):
                track_value = tracks_dict.get((x, y), 0)
                track_row.append(track_value)

        agents = []
        for agent_id in range(max_agent_id+1):
            agents.append(agent_dict[agent_id])

        return tracks, agents


    # Generate environment
    def generate_provided_rail(self, provided_instance):
        rail_generator = sparse_rail_generator()

        tracks, agents = self.get_tracks_agents(provided_instance)

        self.height = len(tracks)
        self.width = len(tracks[0])
        self.number_trains = len(agents)

        grid_map = GridTransitionMap(self.height, self.width)
        grid_map.grid = np.array(tracks, dtype=np.uint16)
        rail_generator = rail_from_grid_transition_map(grid_map)

        # Initialize the properties of the environment
        random_env = RailEnv(
            width=self.width,
            height=self.height,
            rail_generator=rail_generator,
            line_generator=default_line_generator,
            number_of_agents=self.number_trains,
            remove_agents_at_target=True,
            obs_builder_object=DefaultObservationBuilder(),
            random_seed=self.seed
        )

        # Call reset() to initialize the environment
        random_env.reset()

        for agent_id in range(len(agents)):
            prov_agent = agents[agent_id]

            env_agent = random_env.agents[agent_id]
            env_agent.initial_position = prov_agent['initial_position']
            env_agent.initial_direction = prov_agent['initial_direction']
            env_agent.target = prov_agent['target']

            env_agent.earliest_departure = prov_agent['earliest_departure']
            env_agent.latest_arrival = prov_agent['latest_arrival']
            
            env_agent.position = prov_agent['initial_position']
            env_agent.direction = prov_agent['initial_direction']   


        i = 0
        for agent in random_env.agents:
            logging.info(i, 'start: ', agent.initial_position)
            logging.info(i, 'end:   ', agent.target)
            i += 1

        return random_env


    # Generate environment
    def generate_random_rail(self):

        self.width = 22
        self.height = self.width
        self.number_trains = 3

        rail_generator = sparse_rail_generator(
            max_num_cities = 2, 
            grid_mode = False, 
            max_rails_between_cities = 2,
            max_rail_pairs_in_city = 2, 
            seed=None
        )

        # Initialize the properties of the environment
        random_env = RailEnv(
            width=self.width,
            height=self.height,
            number_of_agents=self.number_trains,
            rail_generator=rail_generator,
            line_generator=sparse_line_generator(),
            obs_builder_object=GlobalObsForRailEnv(),
            random_seed=self.seed
        )

        # Call reset() to initialize the environment
        random_env.reset()
        return random_env


    # Render the environment
    def render_env(self, env):
        env_renderer = RenderTool(env, gl="PILSVG")

        env_renderer.render_env(
            show=True,
            show_observations=False,
            show_predictions=False
        )

        image = env_renderer.get_image()
        env_image = PIL.Image.fromarray(image)

        resized_image = env_image.resize((600, 600))

        resized_image.save(INSTANCE_PNG)
        return resized_image


    def env_encoding(self, env):

        x_size = env.width
        y_size = env.height
        number_agents = env.number_of_agents

        encoding_text = (f"% clingo representation of a Flatland environment\n"
        f"% height: {y_size}, width: {x_size}, agents: {number_agents}\n\n")

        for agent_handle in env.get_agent_handles():

            agent = env.agents[agent_handle]
            (y_end, x_end) = agent.target
            (y_start, x_start) = agent.initial_position
            start_direction = REVERSE_DIRECTION_MAP[agent.initial_direction]
            earliest_departure = agent.earliest_departure
            latest_arrival = agent.latest_arrival

            encoding_text += (f"train({agent_handle}). "
            f"start({agent_handle},({y_start},{x_start}),{earliest_departure},{start_direction}). "
            f"end({agent_handle},({y_end},{x_end}),{latest_arrival}).\n\n")

        for y in range(0, y_size):
            for x in range(0, x_size):
                track = env.rail.get_full_transitions(y, x)
                encoding_text += f"cell(({y},{x}), {track}).\n"
            encoding_text += "\n"

        # Check for cached solution
        if os.path.exists(INSTANCE_ASP) and os.path.exists(JSON_OUTPUT):
            with open(INSTANCE_ASP, "r") as instance_file:
                text = instance_file.read()
                if text == encoding_text:

                    with open(JSON_OUTPUT, "r") as output:
                        text = output.read()
                        json_output = json.loads(text)
                        solutions = json_output["Call"][0].get("Witnesses", None)

                        if solutions != None:
                            print('Solution Cached')
                            return False

        with open(INSTANCE_ASP, "w") as instance_file:
            instance_file.write(encoding_text)

        return True


    def run_encoding(self):

        if os.path.exists(JSON_OUTPUT):
            os.remove(JSON_OUTPUT)

        out_file = open(JSON_OUTPUT, "w")

        # Add "0" for all results
        print('Solving...')
        subprocess.call(["clingo", ENCODING_FULL, INSTANCE_ASP, "--outf=2"], stdout=out_file)


    def get_final_positions(self):

        atoms = []
        with open(JSON_OUTPUT, "r") as output:
            text = output.read()
            json_output = json.loads(text)
            solutions = json_output["Call"][0].get("Witnesses", None)

            logging.info(solutions)

            if solutions != None:
                atoms = solutions[-1]["Value"]
            else:
                atoms = []
                logging.WARN('No Solution Found')

        positions_dict = {}

        for atom in atoms:
            # Example: at(0,(18,11),3,1)
            match = re.match(r"at\((?P<agent_id>\w+),\((?P<y>\w+),(?P<x>\w+)\),(?P<dir>\w+),(?P<time>\w+)\)", atom)
            groups = match.groupdict()

            agent_id = groups["agent_id"]
            x = int(groups["x"])
            y = int(groups["y"])
            dir = groups["dir"]
            time = int(groups["time"])

            positions_dict.setdefault(agent_id, {}).setdefault("placements", {})[time] = (x, y, dir)

        for agent_id, _ in positions_dict.items():
            agent_color = "%06x" % random.randint(0, 0xFFFFFF)
            positions_dict[agent_id]["color"] = agent_color
            positions_dict[agent_id]["show"] = True

        return positions_dict


    def set_content(self, image, positions_dict):

        image.content = ""

        for _, agent_data in positions_dict.items():
            agent_color = agent_data["color"]
            show = agent_data["show"]

            y_spacer = 600 / self.height
            x_spacer = 600 / self.width
            font_size = 400 / self.width

            if show:
                for time, place in agent_data["placements"].items():
                    (y, x, dir) = place
                    image.content += (f'<text x="{(x+0.25) * x_spacer}" y="{(y+0.75) * y_spacer}"'
                                      f'stroke="#{agent_color}" stroke-width="1", font-size="{font_size}px">{time}</text>')


    def update_ui(self, event, image, agent_id, positions_dict):
        is_set = event.sender.value

        match = re.match(r"Agent (?P<agent_id>\w+)", event.sender.text)
        groups = match.groupdict()
        agent_id = groups["agent_id"]

        if is_set != positions_dict[agent_id]["show"]:
            positions_dict[agent_id]["show"] = is_set
            self.set_content(image, positions_dict)


    def create_ui(self, env_image, positions_dict):

        image = ui.interactive_image(env_image, cross=True).style("height: 700px")

        self.set_content(image, positions_dict)

        for agent_id, _ in positions_dict.items():

            check = ui.checkbox(f"Agent {agent_id}", on_change=lambda event: self.update_ui(event, image, agent_id, positions_dict))
            check.set_value(positions_dict[agent_id]["show"])

        ui.run(reload=False)
