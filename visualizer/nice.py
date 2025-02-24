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

SEED = 100
random.seed(SEED)

SPACER = 504 / 25

# Generate environment
def generate_rail(x_size, y_size, number_agents, random_seed=SEED):
    rail_generator = sparse_rail_generator()

    # Initialize the properties of the environment
    random_env = RailEnv(
        width=x_size,
        height=y_size,
        number_of_agents=number_agents,
        rail_generator=rail_generator,
        line_generator=sparse_line_generator(),
        obs_builder_object=GlobalObsForRailEnv(),
        random_seed=random_seed
    )

    # Call reset() to initialize the environment
    random_env.reset()
    return random_env


# Render the environment
def render_env(env):
    env_renderer = RenderTool(env, gl="PILSVG")
    env_renderer.render_env()

    image = env_renderer.get_image()
    env_image = PIL.Image.fromarray(image)

    env_image.save('instance.png')
    return env_image


def env_encoding(env):

    x_size = env.width
    y_size = env.height
    number_agents = env.number_of_agents

    encoding_text = (f'% clingo representation of a Flatland environment\n'
    f'% height: {y_size}, width: {x_size}, agents: {number_agents}\n\n')

    for agent_handle in env.get_agent_handles():
        
        direction_map = {
            0: 'n',
            1: 'e',
            2: 's',
            3: 'w'
        }

        agent = env.agents[agent_handle]
        (x_end, y_end) = agent.target
        (x_start, y_start) = agent.initial_position
        start_direction = direction_map[agent.initial_direction]
        earliest_departure = agent.earliest_departure
        latest_arrival = agent.latest_arrival

        encoding_text += (f'train({agent_handle}). '
        f'start({agent_handle},({x_start},{y_start}),{earliest_departure},{start_direction}). '
        f'end({agent_handle},({x_end},{y_end}),{latest_arrival}).\n\n')

    for y in range(0, y_size):
        for x in range(0, x_size):
            track = random_env.rail.get_full_transitions(y, x)
            encoding_text += f'cell(({y},{x}), {track}).\n'
        encoding_text += '\n'

    with open('instance.lp', 'w') as instance_file:
        instance_file.write(encoding_text)

    return encoding_text


def run_encoding():

    out_file = open('output.json', 'w')
    subprocess.call(['clingo', '../encodings/rail_new_actions.lp', 'instance.lp', '0', '--outf=2'], stdout=out_file)


def get_final_positions():

    atoms = []
    with open('output.json', 'r') as output:
        text = output.read()
        json_output = json.loads(text)
        atoms = json_output['Call'][0]['Witnesses'][-1]['Value']

    positions_dict = {}

    for atom in atoms:
        # at(0,(18,11),3,1)
        match = re.match(r'at\((?P<agent_id>\w+),\((?P<x>\w+),(?P<y>\w+)\),(?P<dir>\w+),(?P<time>\w+)\)', atom)
        groups = match.groupdict()

        agent_id = groups['agent_id']
        x = int(groups['x'])
        y = int(groups['y'])
        dir = groups['dir']
        time = int(groups['time'])
        
        positions_dict.setdefault(agent_id, {}).setdefault('placements', {})[time] = (x, y, dir)

    for agent_id, _ in positions_dict.items():
        agent_color = "%06x" % random.randint(0, 0xFFFFFF)
        positions_dict[agent_id]['color'] = agent_color
        positions_dict[agent_id]['show'] = True

    return positions_dict


def set_content(image, positions_dict):

    image.content = ''

    for _, agent_data in positions_dict.items():
        agent_color = agent_data['color']
        show = agent_data['show']

        if show:
            for time, place in agent_data['placements'].items():
                (x, y, dir) = place
                image.content += f'<text x="{(x) * SPACER}" y="{(y+0.5) * SPACER}" stroke="#{agent_color}" stroke-width="1">{time}</text>'


def update_ui(event, image, agent_id):
    is_set = event.sender.value

    match = re.match(r'Agent (?P<agent_id>\w+)', event.sender.text)
    groups = match.groupdict()
    agent_id = groups['agent_id']

    if is_set != positions_dict[agent_id]['show']:
        positions_dict[agent_id]['show'] = is_set
        set_content(image, positions_dict)


def create_ui(env_image, positions_dict):

    image = ui.interactive_image(env_image, cross=True).style("height: 700px")
    
    set_content(image, positions_dict)

    for agent_id, _ in positions_dict.items():

        check = ui.checkbox(f'Agent {agent_id}', on_change=lambda event: update_ui(event, image, agent_id))
        check.set_value(positions_dict[agent_id]['show'])

    ui.run()


random_env = generate_rail(25, 24, 4, random_seed=0)
env_image = render_env(random_env)

env_encoding(random_env)

run_encoding()

positions_dict = get_final_positions()

create_ui(env_image, positions_dict)
