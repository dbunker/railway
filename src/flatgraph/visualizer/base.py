from abc import ABC, abstractmethod


class Visualizer(ABC):

    @abstractmethod
    def visualize(self):
        """Composes a partially ordered plan"""
