# Day 20; Part two

#[
  [Caution]
    This program assumes the following:
      * There is only one input line to the `rx` module, it must come from a conjunction module.
      * All high-pulse input of each input line to the above conjunction module are cyclically,
        and each period starts at the first button pushing.
]#

import std/[assertions, deques, math, options, sequtils, sets, strutils, tables]

# [pulse]
const Low = 0
const High = 1

type
  Pulse = object
    src: string
    dest: string
    level: int  # High/Low

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
    self.level = self.level xor 1  # Low <-> High
    for d in self.dest:
      result.add(Pulse(src: pulse.dest, dest: d, level: self.level))

method input(self: Conj, pulse: Pulse): seq[Pulse] =
  self.src[pulse.src] = pulse.level
  var level = High
  if all(toSeq(self.src.values), proc(x: int): bool = x == High):
    level = Low
  for d in self.dest:
    result.add(Pulse(src: pulse.dest, dest: d, level: level))

# [conjunction checker]
type
  ConjChecker = ref object
    modules: Table[string, seq[int]]

proc hit(self: ConjChecker, name: string, cnt: int): Option[seq[int]] =
  self.modules[name].add(cnt)
  let vals = toSeq(self.modules.values)
  if all(vals, proc(x: seq[int]): bool = x.len >= 2):
    if all(vals, proc(x: seq[int]): bool = x[0] * 2 == x[1]):
      var ret = newSeq[int]()
      for x in vals:
        ret.add(x[0])
      return some(ret)
    else:
      raiseAssert("Can't solve this problem by this program.")

  return none(seq[int])

proc parseData(data: string): (Table[string, Module], string, seq[string]) =
  var tbl = initTable[string, Module]()
  var conjTbl = initTable[string, Conj]()
  var rxPreConjSrc = newSeq[string]()
  var preModule = ""

  for s in splitLines(data):
    let tokens = s.split(" -> ")
    if tokens[0][0] == '%':
      tbl[substr(tokens[0], 1)] = FlipFlop(dest: tokens[1].split(", "), level: Low)
    elif tokens[0][0] == '&':
      conjTbl[substr(tokens[0], 1)] = Conj(dest: tokens[1].split(", "), src: initTable[string, int]())
    else:
      tbl[substr(tokens[0])] = Module(dest: tokens[1].split(", "))

  for conj in conjTbl.keys:
    let conj = conj  # workaround, see https://github.com/nim-lang/Nim/issues/16740
    for k, v in tbl.pairs:
      if any(v.dest, proc (x: string): bool = x == conj) == true:
        conjTbl[conj].src[k] = Low
    for k, v in conjTbl.pairs:
      if any(v.dest, proc (x: string): bool = x == conj) == true:
        conjTbl[conj].src[k] = Low
    tbl[conj] = conjTbl[conj]

    if conjTbl[conj].dest.contains("rx"):
      preModule = conj
      rxPreConjSrc = toSeq(conjTbl[conj].src.keys)

  return (tbl, preModule, rxPreConjSrc)

when isMainModule:
  import std/cmdline
  if paramCount() > 0:
    var (tbl, rxPreConj, rxPreConjSrc) = parseData(readFile(paramStr(1)).strip())

    if rxPreConjSrc.len == 0:
      raiseAssert("There is no conjunction module that outputs to the `rx` module.")
    var tmpTbl = initTable[string, seq[int]]()
    for s in rxPreConjSrc:
      tmpTbl[s] = newSeq[int]()
    var conjChecker = ConjChecker(modules: tmpTbl)
    let conjInputs = toHashSet(rxPreConjSrc)

    var q = initDeque[Pulse]()
    var i = 0
    while true:
      inc(i)
      var pulse = Pulse(src: "button", dest: "broadcaster", level: Low)
      q.addLast(pulse)

      while q.len > 0:
        pulse = q.popFirst()

        if conjInputs.contains(pulse.src) and pulse.dest == rxPreConj and pulse.level == High:
          var tmp = conjChecker.hit(pulse.src, i)
          if tmp.isSome:
            echo(lcm(tmp.get()))
            quit(QuitSuccess)

        if tbl.hasKey(pulse.dest) == false:
          continue
        for p in tbl[pulse.dest].input(pulse):
          q.addLast(p)
