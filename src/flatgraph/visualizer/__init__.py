import time
import warnings
import logging

import clingo

from .base import *
from .view import *


def visualize(instance_path: str, timed: bool = False, provided_instance: str = "") -> None:
    view = VisualizerView()
    view.visualize(instance_path, timed, provided_instance)
