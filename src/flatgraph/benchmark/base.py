from abc import ABC, abstractmethod


class Benchmarker(ABC):

    @abstractmethod
    def generate_benchmarks(self):
        """Generate benchmarks"""

    @abstractmethod
    def run_benchmarks(self):
        """Run generated benchmarks"""

    @abstractmethod
    def generate_statistics(self):
        """Generate statistics from benchmark solutions"""
