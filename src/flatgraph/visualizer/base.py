from abc import ABC, abstractmethod


class Visualizer(ABC):

    @abstractmethod
    def visualize(self):
        """Runs instance solving and visualization"""
