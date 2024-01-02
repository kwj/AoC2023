#!/usr/bin/env python3

# Day 25

# Since I've not found a reliable way to solve such problem, I can only solve it probabilistically.
# I think it is a common solving method of discovering the most used edges by repeating the process
# of creating random minimum spanning trees.
#
# I chose an another method that can solve for the given data this time. But this may just happen
# to give the correct answer, and I think it is a wrong solution.

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


# For a node `v` in the set `S`, return the number of edges connected to nodes other than `S`.
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

    # This algorithm fails if the two nodes which are ends of a wire should be cut are deleted.
    # If group separating fails, one of two groups will be an empty, and the answer, the product
    # of size of two groups, is 0.
    #
    # Therefore, the first node is selected at random, and if the answer is 0, start over.
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
