from abc import ABC, abstractmethod
from typing import Set


class Composer(ABC):

    @abstractmethod
    def compose(self) -> Set[str]:
        """Composes a partially ordered plan"""
