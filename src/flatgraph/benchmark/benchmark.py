import logging
from pathlib import Path

import os
from .base import Benchmarker
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
import pandas as pd
import subprocess
import json
import re
import random
import pathlib
import statistics

ENCODING = "encodings/order_test.lp"
ENCODING_CONNECTIONS = "encodings/back_connections.lp"

ENCODING_FULL = "encodings/rail_new_actions.lp"

BENCHMARK_FOLDER = "generated_benchmarks"

REVERSE_DIRECTION_MAP = {
    0: "n",
    1: "e",
    2: "s",
    3: "w"
}

class BenchmarkGenerator(Benchmarker):

    def __init__(self):
        super().__init__()


    def find_free_cell(self, env, used_positions):
        """
        env: Your RailEnv instance
        used_positions: set of (row, col) positions that are already taken

        Returns a (row, col) tuple for a valid, free cell or raises an error if none is available.
        """
        row_list = list(range(env.height))
        col_list = list(range(env.width))
        random.shuffle(row_list)
        random.shuffle(col_list)

        for row in row_list:
            for col in col_list:
                # Check if this cell is already in use
                if (row, col) in used_positions:
                    continue

                # Optionally, check if the cell has any valid rail transitions
                # so that an agent can actually stand on it.

                possible_directions = []
                for direction in range(4):
                    transitions = env.rail.get_transitions(row, col, direction)
                    if transitions != (0,0,0,0):
                        possible_directions += [direction]

                # If there's at least one valid direction, we'll consider this cell valid
                if len(possible_directions) > 0:
                    random.shuffle(possible_directions)
                    return np.int64(possible_directions[0]), (np.int64(row), np.int64(col))

        raise ValueError("No free cell found in the environment!")


    def create_files(self, params, path):

        for i in range(15):
            env = self.generate_random_rail(params)

            used_cells = set()
            for agent in env.agents:
                # If the agent's initial position is already used, pick a new free cell
                if agent.initial_position in used_cells:
                    agent.initial_direction, agent.initial_position = self.find_free_cell(env, used_cells)
                used_cells.add(agent.initial_position)

            for agent in env.agents:
                # If the agent's target is already used, pick a new free cell
                if agent.target in used_cells:
                    agent.target = self.find_free_cell(env, used_cells)[1]
                used_cells.add(agent.target)

            self.env_encoding(env, f'{path}/instances/instance_{i:02}.lp', f'{path}/solutions/instance_{i:02}.json')
            self.render_env(env, f'{path}/images/instance_{i:02}.png')


    def generate_benchmarks(self):
        
        # sparse_few
        params = {
            "width": 35,
            "height": 35,
            "number_of_agents": 4,
            "max_num_cities": 4, 
            "grid_mode": False, 
            "max_rails_between_cities": 2,
            "max_rail_pairs_in_city": 2, 
        }
        self.create_files(params, f'{BENCHMARK_FOLDER}/sparse_few')

        # sparse_many
        params = {
            "width": 35,
            "height": 35,
            "number_of_agents": 8,
            "max_num_cities": 4, 
            "grid_mode": False, 
            "max_rails_between_cities": 2,
            "max_rail_pairs_in_city": 2, 
        }
        self.create_files(params, f'{BENCHMARK_FOLDER}/sparse_many')

        # dense_few
        params = {
            "width": 35,
            "height": 35,
            "number_of_agents": 4,
            "max_num_cities": 5, 
            "grid_mode": True, 
            "max_rails_between_cities": 5,
            "max_rail_pairs_in_city": 5,
        }
        self.create_files(params, f'{BENCHMARK_FOLDER}/dense_few')

        # dense_many
        params = {
            "width": 35,
            "height": 35,
            "number_of_agents": 8,
            "max_num_cities": 5, 
            "grid_mode": True, 
            "max_rails_between_cities": 5,
            "max_rail_pairs_in_city": 5,
        }
        self.create_files(params, f'{BENCHMARK_FOLDER}/dense_many')


    def create_parents(self, path):
        pathlib.Path('/'.join(path.split('/')[:-1])).mkdir(parents=True, exist_ok=True) 


    def run_benchmarks(self):

        for i in range(15):
            for param_type in ['sparse_few', 'sparse_many', 'dense_few', 'dense_many']:
                for (encoding_type, encoding) in [('solutions', ENCODING_FULL), ('order_solutions', ENCODING)]:
                    path = f'{BENCHMARK_FOLDER}/{param_type}'
                    self.run_encoding(encoding, f'{path}/instances/instance_{i:02}.lp', f'{path}/{encoding_type}/instance_{i:02}.json')


    def get_from_dict(self, data, key_str):
        keys = key_str.split('.')
        for key in keys:
            data = data.get(key)
            if data is None:
                return None
        return data


    def generate_statistics(self):

        #                       Variables, Constraints, Choices, Conflicts, Time
        
        # Baseline
        # Sparse Few
        # Sparse Many
        # Dense Few
        # Dense Many

        # Partial Ordering
        # Sparse Few
        # Sparse Many
        # Dense Few
        # Dense Many

        encoding_map = {
            'Baseline': 'solutions',
            'PartialOdering': 'order_solutions' 
        }

        param_map = {
            "SparseFew": 'sparse_few', 
            "SparseMany": 'sparse_many', 
            "DenseFew": 'dense_few', 
            "DenseMany": 'dense_many'
        }

        stat_map = {
            "Variables": "Stats.Problem.Variables", 
            "Constraints": "Stats.Problem.Constraints.Sum", 
            "Choices": "Stats.Core.Choices",
            "Conflicts": "Stats.Core.Conflicts", 
            "Time": "Time.Total"
        }

        row_labels = param_map.keys()
        column_labels = stat_map.keys()

        for encoding_type in encoding_map.keys():
            df = pd.DataFrame(index=row_labels, columns=column_labels)
            for row_label in row_labels:
                for column_label in column_labels:
                    key_str = stat_map[column_label]

                    stat_list = []
                    for i in range(15):
                        path = f"{BENCHMARK_FOLDER}/{param_map[row_label]}/{encoding_map[encoding_type]}/instance_{i:02}.json"
                        with open(path, "r") as solution_file:
                            json_dict = json.loads(solution_file.read())
                            stat = self.get_from_dict(json_dict, key_str)
                            stat_list += [stat]

                    df.loc[row_label, column_label] = stat_list

            path_start = f"{BENCHMARK_FOLDER}/statistics/{encoding_type}"
            self.create_parents(path)
            df.to_csv(f"{path_start}.csv")

            # Don't include invalid entries
            def validate(func):
                return lambda lst: func([x for x in lst if x != 0 and x != 1])

            # Mean
            df.map(validate(statistics.mean)).to_csv(f"{path_start}Mean.csv")
            
            # Median
            df.map(validate(statistics.median)).to_csv(f"{path_start}Median.csv")

            # Stdev
            df.map(validate(statistics.stdev)).to_csv(f"{path_start}StdDev.csv")


    # Generate environment
    def generate_random_rail(self, params):
        '''
        params:
            width: int
                Width of the environment
            height: int
                Height of the environment
            num_agents:
                Number of agents to be placed within the environment
            max_num_cities : int
                Max number of cities to build. The generator tries to achieve this numbers given all the parameters
            grid_mode: Bool
                How to distribute the cities in the path, either equally in a grid or random
            max_rails_between_cities: int
                Max number of rails connecting to a city. This is only the number of connection points at city boarder.
                Number of tracks drawn inbetween cities can still vary
            max_rail_pairs_in_city: int
                Number of parallel tracks in the city. This represents the number of tracks in the trainstations
        '''

        rail_generator = sparse_rail_generator(
            max_num_cities = params['max_num_cities'],
            grid_mode = params['grid_mode'],
            max_rails_between_cities = params['max_rails_between_cities'],
            max_rail_pairs_in_city = params['max_rail_pairs_in_city']
        )

        # Initialize the properties of the environment
        random_env = RailEnv(
            width=params['width'],
            height=params['height'],
            number_of_agents=params['number_of_agents'],
            rail_generator=rail_generator,
            line_generator=sparse_line_generator(),
            obs_builder_object=GlobalObsForRailEnv()
        )

        # Call reset() to initialize the environment
        random_env.reset()
        return random_env


    # Render the environment
    def render_env(self, env, image_path):
        env_renderer = RenderTool(env, gl="PILSVG")

        env_renderer.render_env(
            show=True,
            show_observations=False,
            show_predictions=False
        )

        image = env_renderer.get_image()
        env_image = PIL.Image.fromarray(image)

        resized_image = env_image.resize((600, 600))

        self.create_parents(image_path)
        resized_image.save(image_path)
        return resized_image


    def env_encoding(self, env, instance_path, solution_path):

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
        if os.path.exists(instance_path) and os.path.exists(solution_path):
            with open(instance_path, "r") as instance_file:
                text = instance_file.read()
                if text == encoding_text:

                    with open(solution_path, "r") as output:
                        text = output.read()
                        json_output = json.loads(text)
                        solutions = json_output["Call"][0].get("Witnesses", None)

                        if solutions != None:
                            print('Solution Cached')
                            return False

        self.create_parents(instance_path)
        with open(instance_path, "w") as instance_file:
            instance_file.write(encoding_text)

        return True


    def run_encoding(self, encoding_file, instance_path, solution_path):

        if os.path.exists(solution_path):
            os.remove(solution_path)

        self.create_parents(solution_path)

        out_file = open(solution_path, "w")

        # Add "0" for all results
        print(f'Solving {instance_path} ...')
        subprocess.call(["clingo", encoding_file, instance_path, "--outf=2", '--stats'], stdout=out_file)

