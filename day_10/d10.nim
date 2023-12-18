# Day 10

import std/strutils
import std/tables


proc parseData(data: string): ((int, int), (int, int), Table[(int, int), char]) =
  var tbl = initTable[(int, int), char]()
  var sx, sy = -1
  var lines = splitLines(data)
  let n_rows = len(lines)
  let n_cols = len(lines[0])

  for x, line in mpairs(lines):
    for y, ch in mpairs(line):
      tbl[(x, y)] = ch
      if ch == 'S':
        (sx, sy) = (x, y)

  return ((n_rows, n_cols), (sx, sy), tbl)


# [IN]
#  pipe: target pipe
#  dir: direction of movement
# [OUT]
#  (direction of arrival, new direction of movement)
#
# example:
#   +-+
#   |F|<--(to West)--
#   +-+
#
#   retrun: ('E', 'S')  // from 'East' to 'South'
#
proc nextDir(pipe: char, dir: char): (char, char) =
  const tbl = {('-', 'E'): ('W', 'E'), ('-', 'W'): ('E', 'W'),
               ('|', 'N'): ('S', 'N'), ('|', 'S'): ('N', 'S'),
               ('F', 'N'): ('S', 'E'), ('F', 'W'): ('E', 'S'),
               ('L', 'S'): ('N', 'E'), ('L', 'W'): ('E', 'N'),
               ('J', 'S'): ('N', 'W'), ('J', 'E'): ('W', 'N'),
               ('7', 'N'): ('S', 'W'), ('7', 'E'): ('W', 'S')}.toTable

  return tbl[(pipe, dir)]


# Find a pipe connected to the start(S[sx, sy]) and return its direction.
proc initDir(sx: int, sy: int, tbl: Table[(int, int), char]): (char, char) =
  var dirs: seq[char]

  if tbl.getOrDefault((sx - 1, sy), '?') in {'7', '|', 'F'}:
    dirs.add('N')
  if tbl.getOrDefault((sx, sy + 1), '?') in {'J', '-', '7'}:
    dirs.add('E')
  if tbl.getOrDefault((sx + 1, sy), '?') in {'J', '|', 'L'}:
    dirs.add('S')
  if tbl.getOrDefault((sx, sy - 1), '?') in {'L', '-', 'F'}:
    dirs.add('W')

  return (dirs[0], dirs[1])


proc getNextPipe(x: int, y: int, dir: char): (int, int) =
  case dir
    of 'N': return (x - 1, y)
    of 'E': return (x, y + 1)
    of 'S': return (x + 1, y)
    of 'W': return (x, y - 1)
    else: assert(false, "Invalid direction")


# Algorithm description for Part one:
#
#  1) Find the starting point
#  2) Follow pipes with recording the direction of travel for each pipe.
#  3) Continue until it returns to the starting point
#
# Algorithm description for Part two:
#
#  Based on the information recorded in Part one, find out if each tile
#  in rows is inside or outside the loop. The decision logic is as follows.
#
#  1) From South to North -> status flag += 2
#
#       | (+1)           | (+1)
#  ==>  |             F--J
#       | (+1)   (+1) |      etc.
#
#  2) From North to South -> status flag -= 2
#
#       | (-1)   (-1) |
#  ==>  |             L--7
#       | (-1)           | (-1)  etc.
#
#  3) Others -> status flag isn't changed (plus-minus zero)
#
#       | (-1)  | (+1)
#  ==>  F-------7           etc.
#
#  If a tile isn't the loop-pipe and the status flag is non-zero,
#  the tile is inside the loop.
#
when isMainModule:
  import std/cmdline
  if paramCount() > 0:
    let data = readFile(paramStr(1))
    let ((n_rows, n_cols), (sx, sy), tbl) = parseData(data.strip())
    var (from_dir, to_dir) = initDir(sx, sy, tbl)

    var loop_pipe = initTable[(int, int), (char, char)]()
    loop_pipe[(sx, sy)] = (from_dir, to_dir)
    var (x, y) = (sx, sy)
    while true:
      (x, y) = getNextPipe(x, y, to_dir)
      if x != sx or y != sy:
        (from_dir, to_dir) = nextDir(tbl[(x, y)], to_dir)
        loop_pipe[(x, y)] = (from_dir, to_dir)
        continue
      else:
        break

    echo("Part one: ", len(loop_pipe) div 2)

    var flag = 0
    var cnt = 0
    for x in countup(1, n_rows - 2):
      for y in countup(0, n_cols - 1):
        if loop_pipe.haskey((x, y)) == true:
          (from_dir, to_dir) = loop_pipe[(x, y)]
          if from_dir == 'S':
            flag += 1
          if to_dir == 'N':
            flag += 1
          if from_dir == 'N':
            flag -= 1
          if to_dir == 'S':
            flag -= 1
        else:
          if flag != 0:
            cnt += 1

    echo("Part two: ", cnt)
