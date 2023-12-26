#!/usr/bin/env python3

# Day 25

import argparse
import sys
from collections import defaultdict
from random import choice

def make_adj_info(lines):
    adj = defaultdict(set)

    for line in lines:
        src, *dests = line.replace(":", "").split(" ")
        for d in dests:
            adj[src].add(d)
            adj[d].add(src)

    return adj


# For each node in the set `S`, return the number of edges to nodes removed from `S`.
def count_connections(v, adj, S):
    return len(adj[v] - S)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'infile', nargs='?', type=argparse.FileType(), default=sys.stdin
    )
    args = parser.parse_args()
    with args.infile as f:
        lines = [x for x in f.read().splitlines()]

    # This algorithm fails if the first two nodes to be deleted are the ends of a wire
    # which should be cut. If group separating fails, one of two groups will be an empty,
    # and the answer, product of size of two groups, is 0.
    #
    # Therefore, the first node is selected at random, and if the answer is 0, start over
    # from the begging.
    adj = make_adj_info(lines)
    ans = 0
    while ans == 0:
        S = set(adj.keys())
        node = choice(list(S))
        S.remove(node)

        while (sum(map(lambda x: count_connections(x, adj, S), S)) > 3):
            node = max(S, key=lambda x: count_connections(x, adj, S))
            S.remove(node)

        ans = len(S) * (len(set(adj.keys()) - S))

    print(ans)
