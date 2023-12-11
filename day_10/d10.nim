# Day 10

import std/options
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
#   |F|<--(W)--
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
               ('7', 'N'): ('S', 'W'), ('7', 'E'): ('W', 'S'),
               ('S', 'N'): ('S', '*'), ('S', 'E'): ('W', '*'),
               ('S', 'S'): ('N', '*'), ('S', 'W'): ('E', '*')}.toTable

  return tbl[(pipe, dir)]


proc initDir(sx: int, sy: int, n_rows: int, n_cols: int, tbl: Table[(int, int), char]): Option[char] =
  if tbl.getOrDefault((sx - 1, sy), '?') in {'7', '|', 'F'}:
    return some('N')
  if tbl.getOrDefault((sx, sy + 1), '?') in {'J', '-', '7'}:
    return some('E')
  if tbl.getOrDefault((sx + 1, sy), '?') in {'J', '|', 'L'}:
    return some('S')
  if tbl.getOrDefault((sx, sy - 1), '?') in {'L', '-', 'F'}:
    return some('W')

  return none(char)


proc getNextPipe(x: int, y: int, dir: char): (int, int) =
  case dir
  of 'N':
    return (x - 1, y)
  of 'E':
    return (x, y + 1)
  of 'S':
    return (x + 1, y)
  of 'W':
    return (x, y - 1)
  else:
    assert(false, "Invalid direction")


# Algorithm for Part two:
#  1) From South to North -> flag += 2
#
#       . (+1)           | (+1)
#  ==>  |             F--J
#       . (+1)   (+1) |      etc.
#
#  2) From North to South -> flag -= 2
#
#       . (-1)   (-1) |
#  ==>  |             L--7
#       . (-1)           | (-1)  etc.
#
#  3) Others -> flag isn't changed (plus-minus zero)
#
#       . (-1)  . (+1)
#  ==>  F-------7           etc.
#
#  If a tile isn't the loop-pipe and the flag is non-zero,
#  the tile is inside the loop.
#
when isMainModule:
  import std/cmdline
  if paramCount() > 0:
    let data = readFile(paramStr(1))
    let ((n_rows, n_cols), (sx, sy), tbl) = parseData(data.strip())
    let init_dir = initDir(sx, sy, n_rows, n_cols, tbl).get

    var from_dir: char
    var to_dir = init_dir
    var (x, y) = (sx, sy)
    var loop_pipe = initTable[(int, int), (char, char)]()

    while true:
      (x, y) = getNextPipe(x, y, to_dir)
      (from_dir, to_dir) = nextDir(tbl[(x, y)], to_dir)

      if x != sx or y != sy:
        loop_pipe[(x, y)] = (from_dir, to_dir)
        continue
      else:
        loop_pipe[(x, y)] = (from_dir, init_dir)
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
