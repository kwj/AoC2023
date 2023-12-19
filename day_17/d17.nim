# Day 17

import std/heapqueue
import std/sequtils
import std/strutils
import std/tables

type
  Grid = seq[seq[uint]]
  Crucible = object
    id: tuple[x: uint, y: uint, dir: uint]
    cost: uint


proc `<`(a, b: Crucible): bool = a.cost < b.cost


proc makeGrid(data: string): Grid =
  return splitLines(data).mapIt(it.mapIt(parseUInt($it)))


proc isInside(grid: Grid, c: Crucible): bool =
  return c.id.x <= uint(high(grid)) and c.id.y <= uint(high(grid[c.id.x]))


proc isGoal(grid: Grid, c: Crucible): bool =
  return c.id.x == uint(high(grid)) and c.id.y == uint(high(grid[high(grid)]))


proc solve(grid: Grid, minSteps: uint, maxSteps: uint): uint =
  # high(uint) means `-1` in the `delta` array..
  #   delta[0]: horizontal movement
  #   delta[1]: vertical movement
  const delta: array[2, array[2, (uint, uint)]] = [[(0, 1), (0, high(uint))], [(1, 0), (high(uint), 0)]]

  var hq = initHeapQueue[Crucible]()
  hq.push(Crucible(id: (0, 0, 0), cost: 0))  # Horizontal
  hq.push(Crucible(id: (0, 0, 1), cost: 0))  # Vertical

  var costs = initTable[(uint, uint, uint), uint]()

  while hq.len > 0:
    var crucible = hq.pop()

    # If there is a minimum cost (heat loss) crucible at the bottom-right block, that is the goal.
    if isGoal(grid, crucible):
      return crucible.cost

    for (dx, dy) in delta[crucible.id.dir]:
      # I don't know why this is working. Deep copy or Copy-on-write?
      # I have not yet found documentation of this behavior.
      var next_c = crucible

      # Change direction of movement
      # `0 xor 1` -> 1, `1 xor 1` -> 0
      next_c.id.dir = next_c.id.dir xor 1

      for step in 1..max_steps:
        next_c.id.x += dx
        next_c.id.y += dy
        if isInside(grid, next_c) == false:
          break
        next_c.cost += grid[next_c.id.x][next_c.id.y]

        if step < minSteps:
          continue

        # This `high(uint)` means that the total heat loss of reaching a block is unknown.
        var crnt_cost = high(uint)
        if costs.hasKey(next_c.id):
          crnt_cost = costs[next_c.id]

        if next_c.cost < crnt_cost:
          costs[next_c.id] = next_c.cost
          hq.push(next_c)


when isMainModule:
  import std/cmdline
  if paramCount() > 0:
    let grid = makeGrid(readFile(paramStr(1)).strip())
    echo("Part one: ", solve(grid, 1, 3))
    echo("Part two: ", solve(grid, 4, 10))
