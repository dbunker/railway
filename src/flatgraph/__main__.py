import argparse
import logging

from .composer import ComposerPartialOrder, compute_instance


def main():
    logging.basicConfig(encoding='utf-8', level=logging.WARNING)

    parser = argparse.ArgumentParser(
        prog="flatgraph",
        description="Graph based flatland solver using partial train ordering",
        epilog="For more questions please consult our project repository on GitHub",
    )
    parser.add_argument("instance")
    parser.add_argument("-t", "--timed", action="store_true")
    args = parser.parse_args()

    compute_instance(args.instance, timed=args.timed)


if __name__ == "__main__":
    main()
