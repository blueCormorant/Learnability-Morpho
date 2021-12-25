#!/usr/bin/env python

import argparse
import logging
from contextlib import ExitStack


def main(args: argparse.Namespace) -> None:
    with ExitStack() as stack:
        in_train_file = stack.enter_context(open(args.train_path, "r"))
        in_dev_file = stack.enter_context(open(args.dev_path, "r"))
        in_test_file = stack.enter_context(open(args.test_path, "r"))

        pres_train_file = stack.enter_context(open("train.eng.pres", "w"))
        past_train_file = stack.enter_context(open("train.eng.past", "w"))
        
        pres_dev_file = stack.enter_context(open("dev.eng.pres", "w"))
        past_dev_file = stack.enter_context(open("dev.eng.past", "w"))
        
        pres_test_file = stack.enter_context(open("test.eng.pres", "w"))
        past_test_file = stack.enter_context(open("test.eng.past", "w"))

        for line in in_train_file:
            pres, past, _ = line.split("\t")
            pres = " ".join(pres)
            past = " ".join(past)
            print(pres, file=pres_train_file)
            print(past, file=past_train_file)

        for line in in_dev_file:
            pres, past, _ = line.split("\t")
            pres = " ".join(pres)
            past = " ".join(past)
            print(pres, file=pres_dev_file)
            print(past, file=past_dev_file)

        for line in in_test_file:
            pres, past, _ = line.split("\t")
            pres = " ".join(pres)
            past = " ".join(past)
            print(pres, file=pres_test_file)
            print(past, file=past_test_file)


if __name__ == "__main__":
    logging.basicConfig(
        level="INFO",
        format="%(levelname)s: %(message)s"
    )
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--train_path",
        type=str,
        required=True,
        help="path to input training data"
    )
    parser.add_argument(
        "--dev_path",
        type=str,
        required=True,
        help="path to input development data"
    )
    parser.add_argument(
        "--test_path",
        type=str,
        required=True,
        help="path to input test data"
    )
    main(parser.parse_args())


