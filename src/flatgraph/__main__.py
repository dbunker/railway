import argparse
import logging

from .composer import compute_instance

from .visualizer import visualize

def main():
    logging.basicConfig(encoding='utf-8', level=logging.WARNING)

    parser = argparse.ArgumentParser(
        prog="flatgraph",
        description="Graph based flatland solver using partial train ordering",
        epilog="For more questions please consult our project repository on GitHub",
    )
    parser.add_argument("instance")
    parser.add_argument("-t", "--timed", action="store_true")
    parser.add_argument("-v", "--visualize", action="store_true")
    args = parser.parse_args()

    if args.visualize:
        visualize(args.instance, timed=args.timed)
    else:
        compute_instance(args.instance, timed=args.timed)

main()
