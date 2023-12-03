#!/usr/bin/env python3

# Day 3: Part one

import argparse
import re
import sys


def make_data(lines):
    line_len = len(lines[0])
    if all(len(x) == line_len for x in lines) is True:
        return line_len + 2, '.' * (line_len + 3) + '..'.join(lines) + '.' * (
            line_len + 3
        )
    else:
        return None


def find_pos_adj_symbol(data, pos, length, offset, re_symbol):
    upper = data[(pos - offset - 1) : (pos - offset - 1 + (length + 2))]
    if (m := re.search(re_symbol, upper)) is not None:
        return (pos - offset - 1) + m.start()

    down = data[(pos + offset - 1) : (pos + offset - 1 + (length + 2))]
    if (m := re.search(re_symbol, down)) is not None:
        return (pos + offset - 1) + m.start()

    left = data[(pos - 1) : pos]
    if (m := re.search(re_symbol, left)) is not None:
        return (pos - 1) + m.start()

    right = data[(pos + length) : (pos + length + 1)]
    if (m := re.search(re_symbol, right)) is not None:
        return (pos + length) + m.start()

    return None


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'infile', nargs='?', type=argparse.FileType(), default=sys.stdin
    )
    args = parser.parse_args()
    with args.infile as f:
        lines = [x for x in f.read().splitlines()]

    if (tpl := make_data(lines)) is None:
        assert False, 'Data format error'

    offset = tpl[0]
    data = tpl[1]
    acc = 0

    for m in re.finditer(r'[0-9]+', data):
        if (
            _ := find_pos_adj_symbol(
                data, m.start(), m.end() - m.start(), offset, r'[^0-9.]'
            )
        ) is not None:
            acc += int(m.group())

    print(acc)
