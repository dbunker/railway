import logging
from pathlib import Path

from .base import Visualizer
from nicegui import events, ui

from flatland.envs.rail_env import RailEnv
from flatland.envs.rail_generators import sparse_rail_generator
from flatland.envs.line_generators import sparse_line_generator
from flatland.envs.observations import GlobalObsForRailEnv

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

class VisualizerView(Visualizer):

    def __init__(self):
        super().__init__()


    def visualize(self, instance_path, timed):
        logging.info("Preprocess Instance")
        print("Generate visual")

        Path(TEMP_FOLDER).mkdir(parents=True, exist_ok=True)
        
        self.seed = 100
        random.seed(self.seed)

        self.width = 22
        self.height = self.width
        self.number_trains = 3

        random_env = self.generate_rail(self.width, self.height, self.number_trains)
        env_image = self.render_env(random_env)

        self.env_encoding(random_env)
        self.run_encoding()

        positions_dict = self.get_final_positions()
        self.create_ui(env_image, positions_dict)


    # Generate environment
    def generate_rail(self, x_size, y_size, number_agents):
        rail_generator = sparse_rail_generator()

        # Initialize the properties of the environment
        random_env = RailEnv(
            width=x_size,
            height=y_size,
            number_of_agents=number_agents,
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
        env_renderer.render_env()

        image = env_renderer.get_image()
        env_image = PIL.Image.fromarray(image)

        env_image.save(INSTANCE_PNG)
        return env_image


    def env_encoding(self, env):

        x_size = env.width
        y_size = env.height
        number_agents = env.number_of_agents

        encoding_text = (f"% clingo representation of a Flatland environment\n"
        f"% height: {y_size}, width: {x_size}, agents: {number_agents}\n\n")

        for agent_handle in env.get_agent_handles():

            direction_map = {
                0: "n",
                1: "e",
                2: "s",
                3: "w"
            }

            agent = env.agents[agent_handle]
            (x_end, y_end) = agent.target
            (x_start, y_start) = agent.initial_position
            start_direction = direction_map[agent.initial_direction]
            earliest_departure = agent.earliest_departure
            latest_arrival = agent.latest_arrival

            encoding_text += (f"train({agent_handle}). "
            f"start({agent_handle},({x_start},{y_start}),{earliest_departure},{start_direction}). "
            f"end({agent_handle},({x_end},{y_end}),{latest_arrival}).\n\n")

        for y in range(0, y_size):
            for x in range(0, x_size):
                track = env.rail.get_full_transitions(y, x)
                encoding_text += f"cell(({y},{x}), {track}).\n"
            encoding_text += "\n"

        with open(INSTANCE_ASP, "w") as instance_file:
            instance_file.write(encoding_text)

        return encoding_text


    def run_encoding(self):

        out_file = open(JSON_OUTPUT, "w")

        # Add "0" for all results
        subprocess.call(["clingo", ENCODING_FULL, INSTANCE_ASP, "--outf=2"], stdout=out_file)


    def get_final_positions(self):

        atoms = []
        with open(JSON_OUTPUT, "r") as output:
            text = output.read()
            json_output = json.loads(text)
            atoms = json_output["Call"][0]["Witnesses"][-1]["Value"]

        positions_dict = {}

        for atom in atoms:
            # Example: at(0,(18,11),3,1)
            match = re.match(r"at\((?P<agent_id>\w+),\((?P<x>\w+),(?P<y>\w+)\),(?P<dir>\w+),(?P<time>\w+)\)", atom)
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

            y_spacer = 504 / (self.height+1)
            x_spacer = 504 / (self.width+1)
            font_size = 8 * (50/self.width)

            if show:
                for time, place in agent_data["placements"].items():
                    (x, y, dir) = place
                    image.content += (f'<text x="{x * x_spacer}" y="{(y+0.5) * y_spacer}"'
                                      f'stroke="#{agent_color}" stroke-width="0.5", font-size="{font_size}px">{time}</text>')


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

        ui.run()
