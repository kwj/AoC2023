#!/usr/bin/env python3

# Day 15: Part two

import argparse
import re
import sys
from functools import reduce


def aoc_hash(s):
    return reduce(lambda acc, x: (acc + ord(x)) * 17 % 256, s, 0)


def parse_line(s):
    m = re.match(r'(\w+)(\W)(.*)', s)
    if m.group(3) == '':
        return [m.group(2), aoc_hash(m.group(1)), m.group(1)]
    else:
        return [m.group(2), aoc_hash(m.group(1)), m.group(1), int(m.group(3))]


def op_sign(tbl, ops):
    box, label, flen = ops
    if box not in tbl:
        tbl[box] = [(label, flen)]
    else:
        for idx, tpl in enumerate(tbl[box]):
            if tpl[0] == label:
                tbl[box][idx] = (label, flen)
                break
        else:
            tbl[box].append((label, flen))


def op_dash(tbl, ops):
    box, label = ops
    if box in tbl:
        tbl[box] = [tpl for tpl in tbl[box] if tpl[0] != label]
        if len(tbl[box]) == 0:
            del tbl[box]


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'infile', nargs='?', type=argparse.FileType(), default=sys.stdin
    )
    args = parser.parse_args()
    with args.infile as f:
        lines = [parse_line(x) for x in f.read().strip().split(',')]

    tbl = {}
    for ops in lines:
        if ops[0] == '=':
            op_sign(tbl, ops[1:])
        elif ops[0] == '-':
            op_dash(tbl, ops[1:])
        else:
            print('[Warning] invalid operation found: {} - Ignored'.format(ops))

    ans = 0
    for k, lst in tbl.items():
        ans += reduce(
            lambda acc, tpl: acc + (k + 1) * tpl[0] * tpl[1][1],
            enumerate(lst, start=1),
            0,
        )

    print(ans)
