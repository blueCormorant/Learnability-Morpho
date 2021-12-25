#!/usr/bin/env python

import argparse
import numpy
import logging
from contextlib import ExitStack


def main(args: argparse.Namespace) -> None:
    # Creates indices for splits.
    with open(args.input_path, "r") as source:
        n_samples = sum(1 for line in source)

    numpy.random.seed(args.seed)
    indices = numpy.random.permutation(n_samples)
    train_ratio = 0.8
    dev_ratio = 0.1

    # Parse custom split ratio
    if args.split_ratio:
        train_ratio, dev_ratio, test_ratio = args.split_ratio.split("-")
        try:
            train_ratio = int(train_ratio)
            dev_ratio = int(dev_ratio)
            test_ratio = int(test_ratio)
        except ValueError as e:
            print("Ratios must have an int value")
            print("Exiting...")
            exit()
        assert train_ratio + dev_ratio + test_ratio == 100, "train + dev + test must be 100"
        train_ratio /= 100
        dev_ratio /= 100
        test_ratio /= 100

    train_right = int(n_samples * train_ratio)
    dev_right = int(n_samples * (train_ratio + dev_ratio))
    logging.info(f"Train set:\t{train_right:,} lines")

    dev_indices = frozenset(indices[train_right:dev_right])
    logging.info(f"Development set:\t{len(dev_indices):,} lines")

    test_indices = frozenset(indices[dev_right:])
    logging.info(f"Test set:\t\t{len(test_indices):,} lines")

    with ExitStack() as stack:
        input_file = stack.enter_context(open(args.input_path, "r"))
        train_file = stack.enter_context(open(args.train_path, "w"))
        dev_file = stack.enter_context(open(args.dev_path, "w"))
        test_file = stack.enter_context(open(args.test_path, "w"))

        for i, line in enumerate(input_file):
            line = line.rstrip()
            if i in dev_indices:
                sink = dev_file
            elif i in test_indices:
                sink = test_file
            else:
                sink = train_file
            print(line, file=sink)

if __name__ == "__main__":
    logging.basicConfig(level="INFO", format="%(levelname)s: %(message)s")
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--seed",
        type=int,
        required=True,
        help="random seed for shuffling data",
    )
    parser.add_argument(
        "--input_path",
        type=str,
        required=True,
        help="path to input data"
    )
    parser.add_argument(
        "--train_path",
        type=str,
        required=True,
        help="path to output training data"
    )
    parser.add_argument(
        "--dev_path",
        type=str,
        required=True,
        help="path to output development data"
    )
    parser.add_argument(
        "--test_path",
        type=str,
        required=True,
        help="path to output test data"
    )
    parser.add_argument(
        "--split_ratio",
        type=str,
        required=False,
        help="three way split ratio (e.g. 80-10-10)"
    )

    main(parser.parse_args())


