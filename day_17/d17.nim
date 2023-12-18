# Day 17

import std/heapqueue
import std/sequtils
import std/strutils
import std/tables

type
  Grid = seq[seq[uint]]
  Node = object
    id: tuple[x: uint, y: uint, dir: uint]
    cost: uint


proc `<`(a, b: Node): bool = a.cost < b.cost


proc makeGrid(data: string): Grid =
  return splitLines(data).mapIt(it.mapIt(parseUInt($it)))


proc isInside(grid: Grid, node: Node): bool =
  return node.id.x <= uint(high(grid)) and node.id.y <= uint(high(grid[node.id.x]))


proc isGoal(grid: Grid, node: Node): bool =
  return node.id.x == uint(high(grid)) and node.id.y == uint(high(grid[high(grid)]))


proc solve(grid: Grid, minSteps: uint, maxSteps: uint): uint =
  # high(uint) means `-1`.
  #   delta[0]: horizontal movement
  #   delta[1]: vertical movement
  const delta: array[2, array[2, (uint, uint)]] = [[(0, 1), (0, high(uint))], [(1, 0), (high(uint), 0)]]

  var hq = initHeapQueue[Node]()
  hq.push(Node(id: (0, 0, 0), cost: 0))  # Horizontal
  hq.push(Node(id: (0, 0, 1), cost: 0))  # Vertical

  var costs = initTable[(uint, uint, uint), uint]()

  while hq.len > 0:
    var node = hq.pop()

    # If a minimum heat loss node is the bottom-right block, that is the goal.
    if isGoal(grid, node):
      return node.cost

    for (dx, dy) in delta[node.id.dir]:
      var next_node = node

      # Change of direction of movement
      # `0 xor 1` -> 1, `1 xor 1` -> 0
      next_node.id.dir = next_node.id.dir xor 1

      for step in 1..max_steps:
        next_node.id.x += dx
        next_node.id.y += dy
        if isInside(grid, next_node) == false:
          break
        next_node.cost += grid[next_node.id.x][next_node.id.y]

        if step < minSteps:
          continue

        var crnt_cost = high(uint)
        if costs.hasKey(next_node.id):
          crnt_cost = costs[next_node.id]

        if next_node.cost < crnt_cost:
          costs[next_node.id] = next_node.cost
          hq.push(next_node)


when isMainModule:
  import std/cmdline
  if paramCount() > 0:
    let grid = makeGrid(readFile(paramStr(1)).strip())
    echo("Part one: ", solve(grid, 1, 3))
    echo("Part two: ", solve(grid, 4, 10))
