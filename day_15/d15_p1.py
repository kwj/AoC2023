#!/usr/bin/env python3

# Day 15: Part one

import argparse
import sys
from functools import reduce


def aoc_hash(s):
    return reduce(lambda acc, x: (acc + ord(x)) * 17 % 256, s, 0)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'infile', nargs='?', type=argparse.FileType(), default=sys.stdin
    )
    args = parser.parse_args()
    with args.infile as f:
        print(sum(aoc_hash(x) for x in f.read().strip().split(',')))
