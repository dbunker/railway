import argparse
import logging

from .composer import compute_instance

from .visualizer import visualize

from .benchmark import generate_benchmarks
from .benchmark import run_benchmarks
from .benchmark import generate_statistics

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
    parser.add_argument("-p", "--provided", default="")

    parser.add_argument("-g", "--generate_benchmarks", action="store_true")
    parser.add_argument("-r", "--run_benchmarks", action="store_true")
    parser.add_argument("-s", "--generate_statistics", action="store_true")
    args = parser.parse_args()

    if args.visualize:
        visualize(args.instance, timed=args.timed, provided_instance=args.provided)
    elif args.generate_benchmarks:
        generate_benchmarks()
    elif args.run_benchmarks:
        run_benchmarks()
    elif args.generate_statistics:
        generate_statistics()
    else:
        compute_instance(args.instance, timed=args.timed)


if __name__ == "__main__":
    main()
