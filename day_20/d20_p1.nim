# Day 20; Part one

import std/[deques, sequtils, strutils, tables]

# [pulse]
const Low = 0
const High = 1

type
  Pulse = object
    src: string
    dest: string
    level: int

# [modules]
type
  Module = ref object of RootObj
    dest: seq[string]
  FlipFlop = ref object of Module
    level: int
  Conj = ref object of Module
    src: Table[string, int]

method input(self: Module, pulse: Pulse): seq[Pulse] {.base.} =
  for d in self.dest:
    result.add(Pulse(src: pulse.dest, dest: d, level: Low))

method input(self: FlipFlop, pulse: Pulse): seq[Pulse] =
  if pulse.level == Low:
    self.level = self.level xor 1
    for d in self.dest:
      result.add(Pulse(src: pulse.dest, dest: d, level: self.level))

method input(self: Conj, pulse: Pulse): seq[Pulse] =
  self.src[pulse.src] = pulse.level
  var level = High
  if all(toSeq(self.src.values), proc(x: int): bool = x == High):
    level = Low
  for d in self.dest:
    result.add(Pulse(src: pulse.dest, dest: d, level: level))

proc parseData(data: string): Table[string, Module] =
  var conjTbl = initTable[string, Conj]()

  for s in splitLines(data):
    let tokens = s.split(" -> ")
    if tokens[0][0] == '%':
      result[substr(tokens[0], 1)] = FlipFlop(dest: tokens[1].split(", "), level: Low)
    elif tokens[0][0] == '&':
      conjTbl[substr(tokens[0], 1)] = Conj(dest: tokens[1].split(", "), src: initTable[string, int]())
    else:
      result[substr(tokens[0])] = Module(dest: tokens[1].split(", "))

  for conj in conjTbl.keys:
    let conj = conj  # workaround, see https://github.com/nim-lang/Nim/issues/16740
    for k, v in result.pairs:
      if any(v.dest, proc (x: string): bool = x == conj) == true:
        conjTbl[conj].src[k] = Low
    for k, v in conjTbl.pairs:
      if any(v.dest, proc (x: string): bool = x == conj) == true:
        conjTbl[conj].src[k] = Low
    result[conj] = conjTbl[conj]

when isMainModule:
  import std/cmdline
  if paramCount() > 0:
    var tbl = parseData(readFile(paramStr(1)).strip())
    var lowCnt = 0
    var highCnt = 0
    var q = initDeque[Pulse]()

    for i in 1..1000:
      var pulse = Pulse(src: "button", dest: "broadcaster", level: Low)
      q.addLast(pulse)

      while q.len > 0:
        pulse = q.popFirst()

        if pulse.level == High:
          highCnt += 1
        else:
          lowCnt += 1

        if tbl.hasKey(pulse.dest) == false:
          continue
        for p in tbl[pulse.dest].input(pulse):
          q.addLast(p)

    echo(low_cnt * high_cnt)
