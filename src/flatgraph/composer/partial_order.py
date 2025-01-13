from dataclasses import dataclass
from enum import Enum
from typing import Set, Dict, Optional

import clingo

from .base import Composer


# https://stackoverflow.com/questions/29503339/how-to-get-all-values-from-python-enum-class
class ExtendedEnum(Enum):

    @classmethod
    def list(cls):
        return list(map(lambda c: c.value, cls))


class Action(ExtendedEnum):
    MOVE_FORWARD = "move_forward"
    MOVE_LEFT = "move_left"
    MOVE_RIGHT = "move_right"
    WAIT = "wait"


@dataclass
class Node:
    x: int
    y: int

    def __hash__(self):
        return hash((self.x, self.y))

    def __str__(self) -> str:
        return f"({str(self.x).rjust(3)},{str(self.y).rjust(3)})"


@dataclass
class DirectedNode:
    node: Node
    direction: int

    def __hash__(self):
        return hash((self.node, self.direction))


@dataclass
class Train:
    train_id: int

    def __hash__(self):
        return hash(self.train_id)


@dataclass
class Move:
    node_from: DirectedNode
    node_to: DirectedNode

    def __hash__(self):
        return hash((self.node_from, self.node_to))


@dataclass
class Transition:
    node: Node
    action: Action

    def __hash__(self):
        return hash((self.node, self.action))


@dataclass
class PartialOrder:
    before: Train
    after: Train

    def __hash__(self):
        return hash((self.before, self.after))


class ComposerPartialOrder(Composer):

    def __init__(self, order_plan: Set[str]):
        super().__init__()
        self.order_plan = order_plan

        self.moves: Dict[Train, Set[Move]] = {}
        self.trains: Set[Train] = set()
        self.nodes: Set[Node] = set()
        self.order: Dict[Node, Set[PartialOrder]] = {}

        self.edges_real: Dict[Node, Set[Transition]] = {}

        self.preprocess()

    def preprocess(self):
        for move in [a for a in self.order_plan if a.startswith("move")]:
            symbol = clingo.parse_term(move)

            train_id = symbol.arguments[0]
            node_from = symbol.arguments[1]
            node_to = symbol.arguments[2]

            train = Train(int(str(train_id)))
            self.trains.add(train)

            node_from = parse_directed_node(node_from)
            node_to = parse_directed_node(node_to)
            self.nodes.add(node_from.node)
            self.nodes.add(node_to.node)

            print(train, node_from, node_to)
            if train in self.moves:
                self.moves[train].add(Move(node_from, node_to))
            else:
                self.moves[train] = {Move(node_from, node_to)}

        for resolve in [a for a in self.order_plan if a.startswith("resolve")]:
            symbol = clingo.parse_term(resolve)

            before = parse_train(symbol.arguments[0])
            after = parse_train(symbol.arguments[1])
            node = parse_node(symbol.arguments[2])

            if node in self.order:
                self.order[node].add(PartialOrder(before, after))
            else:
                self.order[node] = {PartialOrder(before, after)}

        for edge in [a for a in self.order_plan if a.startswith("edge")]:
            symbol = clingo.parse_term(edge)

            node_from = parse_node(symbol.arguments[0])
            node_to = parse_node(symbol.arguments[2])
            action = parse_action(symbol.arguments[4])

            self.nodes.add(node_from)
            self.nodes.add(node_to)

            if node_from in self.edges_real:
                self.edges_real[node_from].add(Transition(node_to, action))
            else:
                self.edges_real[node_from] = {Transition(node_to, action)}

        print(self.status())

    def simulate(self) -> None:
        pass

    def compose(self) -> Set[str]:
        self.simulate()
        return set()

    def status(self) -> str:
        out = "\n"
        out += f"Trains: {self.trains}\n"
        out += f"Nodes: {self.nodes}\n"
        out += "Moves: \n"
        for train, moves in self.moves.items():
            out += f"\t{train}:\n"
            for move in moves:
                out += f"\t\t{move}\n"
        out += "Order: \n"
        for node, orders in self.order.items():
            out += f"\t{node}:\n"
            for order in orders:
                out += f"\t\t{order}\n"
        out += "Edges (Real): \n"
        out += self.adjacency_real()
        return out

    def adjacency_real(self) -> str:
        sorted_nodes = sorted(self.nodes, key=lambda n: (n.x, n.y))
        out = "-" * 9 + " " + " ".join([str(n) for n in sorted_nodes]) + "\n"
        for node in sorted_nodes:
            out += f"{node} "
            adjacency = []
            for target in sorted_nodes:
                adjacency.append(
                    target
                    in [
                        transition.node
                        for transition in self.edges_real[node]
                        if transition.action != Action.WAIT
                    ]
                )

            out += (
                " ".join(["[XXXXXXX]" if adj else "[       ]" for adj in adjacency])
                + "\n"
            )
        return out


def parse_directed_node(node: clingo.Symbol) -> DirectedNode:
    direction = node.arguments[1]
    node = parse_node(node.arguments[0])
    return DirectedNode(node=node, direction=int(str(direction)))


def parse_node(node: clingo.Symbol) -> Node:
    (x, y) = node.arguments
    return Node(int(str(x)), int(str(y)))


def parse_train(train: clingo.Symbol) -> Train:
    return Train(int(str(train)))


def parse_action(action: clingo.Symbol) -> Action:
    for action_str in Action.list():
        if str(action) == action_str:
            return Action(action_str)
    raise ValueError(f"{action} is not a valid action")
