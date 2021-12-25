#!/usr/bin/env python
"""Error analysis on fairseq-generate output. Calculates
word error rate and average edit distance for word pairs.
"""

import argparse
import re
from Levenshtein import distance

from typing import Iterable, List, Tuple

# fairseq-generate parsing.


LOG_STATEMENT = r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} | INFO"
FINAL_STATEMENT = r"Generate (\w)+ with"

Sequence = List[str]

def _output(path: str) -> Iterable[Tuple[Sequence, Sequence, Sequence, float]]:
    """Generates source, target, hypothesis, and posterior score tuples."""
    with open(path, "r") as generate:
        while True:
            try:
                line = next(generate)
            except StopIteration:
                return
            if re.match(LOG_STATEMENT, line):
                continue
            if re.match(FINAL_STATEMENT, line):
                return
            # Otherwise, the format is:
            # S: "source"
            # T: "target"
            # H: score <tab> "hypothesis"
            # D: score <tab> "detokenized hypothesis"
            # P: positional scores per token.
            # We extract S, T, H, and H's score.
            assert line.startswith("S-"), line
            _, source_str = line.split("\t", 1)
            source = source_str.split()
            line = next(generate)
            assert line.startswith("T-"), line
            _, target_str = line.split("\t", 1)
            target = target_str.split()
            line = next(generate)
            assert line.startswith("H-"), line
            _, score_str, hypothesis_str = line.split("\t", 2)
            score = float(score_str)
            hypothesis = hypothesis_str.split()
            # TODO: I think there can be multiple hypotheses per S/T pair, but
            # this is not yet supported.
            yield source, target, hypothesis, score
            # Skips over the next two.
            line = next(generate)
            assert line.startswith("D-"), line
            line = next(generate)
            assert line.startswith("P-"), line


def main(args: argparse.Namespace) -> None:
    error = 0
    total = 0
    lev_sum = 0
    for src_lst, tgt_lst, hyp_lst, _ in _output(args.pred):
        src = " ".join(src_lst)
        tgt = " ".join(tgt_lst)
        hyp = " ".join(hyp_lst)
        if tgt != hyp:
            error += 1
            print(src)
            print(tgt)
            print(hyp)
            print("")
        total += 1
        tgt_nosp = "".join(tgt_lst)
        hyp_nosp = "".join(hyp_lst)
        edit_dist = distance(tgt_nosp, hyp_nosp)
        lev_sum += edit_dist
    
    wer = 100 * error / total
    lev_avg = lev_sum / total

    print(f"Got {error} errors")
    print(f"WER:\t{wer:.2f}")
    print(f"EDIT AVG:\t{lev_avg:.2f}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pred", help="pred file path")
    main(parser.parse_args())
