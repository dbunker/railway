import time
import warnings
import logging

import clingo

from .base import *
from .benchmark import *


def generate_benchmarks() -> None:
    benchmarker = BenchmarkGenerator()
    benchmarker.generate_benchmarks()

def run_benchmarks() -> None:
    benchmarker = BenchmarkGenerator()
    benchmarker.run_benchmarks()

def generate_statistics() -> None:
    benchmarker = BenchmarkGenerator()
    benchmarker.generate_statistics()
