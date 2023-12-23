# Day 10

#[
  I learned about the Shoelace formula on Day 18,
  So, I wrote another program.

  Shoelace formula and Pick's theorem
    https://en.wikipedia.org/wiki/Shoelace_formula
    https://en.wikipedia.org/wiki/Pick%27s_theorem
]#

import std/[sequtils, strutils, tables]

type
  Point = tuple[x: int, y: int]

proc parseData(data: string): (Point, Table[Point, char]) =
  var grid = initTable[Point, char]()
  var sx, sy = -1
  var lines = splitLines(data)

  for x, line in mpairs(lines):
    for y, ch in mpairs(line):
      grid[(x, y)] = ch
      if ch == 'S':
        (sx, sy) = (x, y)

  return ((sx, sy), grid)

# [IN]
#  pipe: target pipe
#  dir: direction of movement
# [OUT]
#  new direction of movement
#
# example:
#   +-+
#   |F|<--(to West)--
#   +-+
#
#   retrun: 'S'  // toward 'South'
#
proc nextDir(pipe: char, dir: char): char =
  const tbl = {('-', 'E'): 'E', ('-', 'W'): 'W',
               ('|', 'N'): 'N', ('|', 'S'): 'S',
               ('F', 'N'): 'E', ('F', 'W'): 'S',
               ('L', 'S'): 'E', ('L', 'W'): 'N',
               ('J', 'S'): 'W', ('J', 'E'): 'N',
               ('7', 'N'): 'W', ('7', 'E'): 'S'}.toTable

  return tbl[(pipe, dir)]

# Find a pipe connected to the starting point (S), and return its direction and
# the whether the starting point is a turn or not.
proc initDir(s: Point, grid: Table[Point, char]): (char, bool) =
  var dirs: seq[char]
  var isTurn: bool

  if grid.getOrDefault((s.x - 1, s.y), '?') in {'7', '|', 'F'}:
    dirs.add('N')
  if grid.getOrDefault((s.x, s.y + 1), '?') in {'J', '-', '7'}:
    dirs.add('E')
  if grid.getOrDefault((s.x + 1, s.y), '?') in {'J', '|', 'L'}:
    dirs.add('S')
  if grid.getOrDefault((s.x, s.y - 1), '?') in {'L', '-', 'F'}:
    dirs.add('W')

  if dirs[0] == 'E' and dirs[1] == 'W':
    isTurn = false
  elif dirs[0] == 'W' and dirs[1] == 'E':
    isTurn = false
  elif dirs[0] == 'N' and dirs[1] == 'S':
    isTurn = false
  elif dirs[0] == 'S' and dirs[1] == 'N':
    isTurn = false
  else:
    isTurn = true

  return (dirs[0], isTurn)

proc getNextPipe(x: int, y: int, dir: char): (int, int) =
  case dir
    of 'N': return (x - 1, y)
    of 'E': return (x, y + 1)
    of 'S': return (x + 1, y)
    of 'W': return (x, y - 1)
    else: assert(false, "Invalid direction")

proc partition[T](sq: seq[T]): seq[(T, T)] =
  for i in low(sq)..<high(sq):
    result.add((sq[i], sq[i+1]))

proc calcArea(points: seq[(Point, Point)]): int =
  let lst = map(points, proc(tpl: (Point, Point)): int =
              let (p1, p2) = tpl
              p1.x * p2.y - p1.y * p2.x)
  result = abs(foldl(lst, a + b, 0)) div 2

when isMainModule:
  import std/cmdline
  if paramCount() > 0:
    let data = readFile(paramStr(1))
    let (start, grid) = parseData(data.strip())

    var (toDir, isTurn) = initDir(start, grid)
    var turnPoints = newSeq[Point]()
    if isTurn == true:
      turnPoints.add(start)
    var (x, y) = start
    var steps = 0
    while true:
      steps += 1
      (x, y) = getNextPipe(x, y, toDir)
      if grid[(x, y)] in {'L', '7', 'F', 'J'}:
        turnPoints.add((x, y))

      if x != start.x or y != start.y:
        toDir = nextDir(grid[(x, y)], toDir)
        continue
      else:
        break

    echo("Part one: ", steps div 2)

    # Use Shoelace formula and Pick's theorem
    turnPoints.add(turnPoints[0])
    echo("Part two: ", calcArea(partition(turnPoints)) - (steps div 2) + 1)
