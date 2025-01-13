import argparse

from .composer import ComposerPartialOrder, compute_instance


def main():
    parser = argparse.ArgumentParser(
        prog="flatgraph",
        description="Graph based flatland solver using partial train ordering",
        epilog="For more questions please consult our project repository on GitHub",
    )
    parser.add_argument("instance")
    args = parser.parse_args()

    print("flatgraph\n")

    compute_instance(args.instance)


if __name__ == "__main__":
    main()
