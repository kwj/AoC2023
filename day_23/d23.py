#!/usr/bin/env python3

# Day 23

import argparse
import copy
import sys

# Constants (global)
NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

reversal = [SOUTH, WEST, NORTH, EAST]
dx = [-1, 0, 1, 0]
dy = [0, 1, 0, -1]


class Node:
    def __init__(self, r, c, adj_dir, /, is_start=False, is_end=False):
        self.r = r
        self.c = c
        self.adj_dir = adj_dir
        self.adj = []
        self.is_start = is_start
        self.is_end = is_end
        self.visited = False


def parse_maze(maze):
    nodes = dict()
    M, N = len(maze), len(maze[0])
    sx, sy = 0, maze[0].index('.')
    gx, gy = M - 1, maze[-1].index('.')

    nodes[(sx, sy)] = Node(sx, sy, [SOUTH], is_start=True)
    nodes[(gx, gy)] = Node(gx, gy, [NORTH], is_end=True)
    maze[sx][sy] = 'S'
    maze[gx][gy] = 'G'

    for x in range(1, M - 1):
        for y in range(1, N - 1):
            if maze[x][y] == '#':
                continue
            tmp = []
            for i in [NORTH, EAST, SOUTH, WEST]:
                if maze[x + dx[i]][y + dy[i]] in '#SG':
                    continue
                else:
                    tmp.append(i)
            if len(tmp) > 2:
                nodes[(x, y)] = Node(x, y, tmp)

    return (sx, sy), nodes


def set_adj_node(r, c, direct, nodes, is_slip=False):
    slip = ['v', '<', '^', '>']
    positions = nodes.keys()

    x = r + dx[direct]
    y = c + dy[direct]
    if is_slip is True and maze[x][y] == slip[direct]:
        return
    cnt = 1

    while (x, y) not in positions:
        for i in [NORTH, EAST, SOUTH, WEST]:
            if i == reversal[direct]:
                continue
            if maze[x + dx[i]][y + dy[i]] == '#':
                continue
            if maze[x + dx[i]][y + dy[i]] in '.SG' or is_slip is False:
                x += dx[i]
                y += dy[i]
                direct = i
                break
            if is_slip is True:
                if maze[x + dx[i]][y + dy[i]] == slip[i]:
                    return
                else:
                    x += dx[i]
                    y += dy[i]
                    direct = (slip.index(maze[x][y]) + 2) % 4
                    x += dx[direct]
                    y += dy[direct]
                    cnt += 1
                    break
        else:
            return

        cnt += 1

    nodes[(r, c)].adj.append((cnt, nodes[(x, y)]))

    return


def set_edge_info(nodes, is_slip=False):
    for pos, node in nodes.items():
        while len(node.adj_dir) > 0:
            set_adj_node(pos[0], pos[1], node.adj_dir.pop(), nodes, is_slip)

    return nodes


def find_longest_steps(node, acc, max_steps):
    if node.is_end is True:
        return max(acc, max_steps)
    else:
        node.visited = True
        for dist, next_node in node.adj:
            if next_node.visited is False:
                max_steps = find_longest_steps(next_node, acc + dist, max_steps)
        node.visited = False

        return max_steps


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'infile', nargs='?', type=argparse.FileType(), default=sys.stdin
    )
    args = parser.parse_args()
    with args.infile as f:
        maze = [list(x) for x in f.read().splitlines()]

    start_pos, nodes_p1 = parse_maze(maze)
    nodes_p2 = copy.deepcopy(nodes_p1)

    set_edge_info(nodes_p1, is_slip=True)
    print("Part one:", find_longest_steps(nodes_p1[start_pos], 0, 0))

    set_edge_info(nodes_p2, is_slip=False)
    print("Part two:", find_longest_steps(nodes_p2[start_pos], 0, 0))
