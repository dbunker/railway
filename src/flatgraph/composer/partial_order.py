import logging
from dataclasses import dataclass, field
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

    __repr__ = __str__


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
class MoveUndirected:
    node_from: Node
    node_to: Node

    def __hash__(self):
        return hash((self.node_from, self.node_to))


@dataclass
class Move:
    node_from: DirectedNode
    node_to: DirectedNode

    def to_undirected(self) -> MoveUndirected:
        return MoveUndirected(self.node_from.node, self.node_to.node)

    def __hash__(self):
        return hash((self.node_from, self.node_to))


@dataclass
class Transition:
    node: Node
    direction_in: int
    direction_out: int
    action: Action

    def __hash__(self):
        return hash((self.node, self.action))


@dataclass
class PartialOrder:
    before: Train
    after: Train

    def __hash__(self):
        return hash((self.before, self.after))


@dataclass
class TrainSimulator:
    train: Train
    position: Node
    direction: int
    last_update: int = 0
    current_move: Optional[Move] = None
    goal_reached: bool = False
    passed_nodes: Set[Node] = field(default_factory=set)


class ComposerPartialOrder(Composer):

    def __init__(self, order_plan: Set[str]):
        super().__init__()
        self.order_plan = order_plan

        self.moves: Dict[Train, Set[Move]] = {}
        self.trains: Set[Train] = set()
        self.nodes: Set[Node] = set()
        self.order: Dict[Node, Set[PartialOrder]] = {}

        self.starts: Dict[Train, DirectedNode] = {}
        self.goals: Dict[Train, Node] = {}
        self.edges_real: Dict[Node, Set[Transition]] = {}
        self.move_connections: Dict[Move, Set[MoveUndirected]] = {}

        self.preprocess()

    def preprocess(self):
        logging.info("Preprocess Instance")
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

        for start in [a for a in self.order_plan if a.startswith("node_start")]:
            symbol = clingo.parse_term(start)

            node = parse_directed_node(symbol.arguments[0])
            train = parse_train(symbol.arguments[1])

            self.starts[train] = node

        for goal in [a for a in self.order_plan if a.startswith("node_end")]:
            symbol = clingo.parse_term(goal)

            node = parse_node(symbol.arguments[0].arguments[0])
            train = parse_train(symbol.arguments[1])

            self.goals[train] = node

        for edge in [a for a in self.order_plan if a.startswith("edge")]:
            symbol = clingo.parse_term(edge)

            node_from = parse_node(symbol.arguments[0])
            node_from_dir = int(str(symbol.arguments[1]))
            node_to = parse_node(symbol.arguments[2])
            node_to_dir = int(str(symbol.arguments[3]))
            action = parse_action(symbol.arguments[4])

            self.nodes.add(node_from)
            self.nodes.add(node_to)

            if node_from in self.edges_real:
                self.edges_real[node_from].add(Transition(node_to, node_from_dir, node_to_dir, action))
            else:
                self.edges_real[node_from] = {Transition(node_to, node_from_dir, node_to_dir, action)}

        for connection in [
            a
            for a in self.order_plan
            if a.startswith("connection") and len(clingo.parse_term(a).arguments) == 5
        ]:
            symbol = clingo.parse_term(connection)

            move_start = parse_directed_node(symbol.arguments[0])
            move_end = parse_directed_node(symbol.arguments[1])
            node_from = parse_node(symbol.arguments[2])
            node_to = parse_node(symbol.arguments[3])

            move = Move(move_start, move_end)
            if move in self.move_connections:
                self.move_connections[move].add(MoveUndirected(node_from, node_to))
            else:
                self.move_connections[move] = {MoveUndirected(node_from, node_to)}

    def simulate(self) -> None:
        logging.info("Simulate Train Movements")

        train_sims = {
            train: TrainSimulator(train, self.starts[train].node, self.starts[train].direction) for train in self.trains
        }
        action_log = set()
        time = 0

        while True:
            time += 1
            for _, train in train_sims.items():
                # skip arrived trains
                if train.goal_reached:
                    continue

                # select new move
                if train.current_move is None:
                    move = self.get_move_at_node(train.train, train.position)
                    train.current_move = move
                # check if next node can be entered
                next_transition = self.get_next_transition(train)
                can_enter = self.can_enter_node(train.train, next_transition.node, train_sims)
                if can_enter:
                    # move train
                    last_node = train.position
                    train.passed_nodes.add(last_node)
                    train.position = next_transition.node
                    train.direction = next_transition.direction_out
                    train.last_update = time
                    action_log.add((train.train.train_id, time, next_transition.action, last_node, next_transition.node))
                else:
                    # wait
                    action_log.add((train.train.train_id, time, Action.WAIT, train.position))
                # update current move
                if train.position == train.current_move.node_to.node:
                    train.current_move = None
                    # goal condition
                    if train.position == self.goals[train.train]:
                        train.goal_reached = True

            if all([train.goal_reached for train in train_sims.values()]):
                for action in sorted(action_log, key=lambda a: (a[0], a[1])):
                    print(f"{ComposerPartialOrder._format_action(action[0], action[1], action[2])}.")
                break

    @staticmethod
    def _format_action(train_id: int, timestep: int, action: Action) -> clingo.Symbol:
        return clingo.parse_term(f"action(train({train_id}), {timestep}, {action.value})")

    def compose(self) -> Set[str]:
        self.simulate()
        logging.info("Actions Generated")
        return set()

    def get_move_at_node(self, train: Train, node: Node) -> Move:
        for move in self.moves[train]:
            if move.node_from.node == node:
                return move

    def get_next_transition(self, train: TrainSimulator) -> Transition:
        moves = self.move_connections[train.current_move]
        for move in moves:
            if move.node_from == train.position:
                transition = self.get_move_transition(move, train.direction)
                return transition

    def get_move_transition(self, move: MoveUndirected, direction: int) -> Transition:
        transitions = self.edges_real[move.node_from]
        for transition in transitions:
            if transition.node == move.node_to and transition.direction_in == direction:
                return transition

    def can_enter_node(self, train: Train, node: Node, trains: Dict[Train, TrainSimulator]) -> bool:
        if node not in self.order:
            return True
        results = []
        for order in self.order[node]:
            if train == order.after:
                can_enter = node in trains[order.before].passed_nodes
                results.append(can_enter)
        return all(results)

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
