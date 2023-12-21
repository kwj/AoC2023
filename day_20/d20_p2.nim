# Day 20; Part two

import std/assertions
import std/deques
import std/math
import std/options
import std/sequtils
import std/sets
import std/strutils
import std/tables

const Low = 0
const High = 1

type
  Pulse = object
    src: string
    dest: string
    level: int

type
  Module = ref object of RootObj
    dest: seq[string]

method input(self: Module, pulse: Pulse): seq[Pulse] {.base.} =
  for d in self.dest:
    result.add(Pulse(src: pulse.dest, dest: d, level: Low))

type
  FlipFlop = ref object of Module
    level: int

method input(self: FlipFlop, pulse: Pulse): seq[Pulse] =
  if pulse.level == Low:
    self.level = self.level xor 1
    for d in self.dest:
      result.add(Pulse(src: pulse.dest, dest: d, level: self.level))

type
  Conj = ref object of Module
    src: Table[string, int]

method input(self: Conj, pulse: Pulse): seq[Pulse] =
  self.src[pulse.src] = pulse.level
  var level = High
  if all(toSeq(self.src.values), proc(x: int): bool = x == High):
    level = Low
  for d in self.dest:
    result.add(Pulse(src: pulse.dest, dest: d, level: level))

type
  RxChecker = ref object
    modules: Table[string, seq[int]]

proc hit(self: RxChecker, name: string, cnt: int): Option[seq[int]] =
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
  var conj_tbl = initTable[string, Conj]()
  var p2_conj_src = newSeq[string]()
  var preModule = ""

  for s in splitLines(data):
    let tokens = s.split(" -> ")
    if tokens[0][0] == '%':
      tbl[substr(tokens[0], 1)] = FlipFlop(dest: tokens[1].split(", "), level: Low)
    elif tokens[0][0] == '&':
      conj_tbl[substr(tokens[0], 1)] = Conj(dest: tokens[1].split(", "), src: initTable[string, int]())
    else:
      tbl[substr(tokens[0])] = Module(dest: tokens[1].split(", "))

  for conj in conj_tbl.keys:
    let conj = conj  # workaround, see https://github.com/nim-lang/Nim/issues/16740
    for k, v in tbl.pairs:
      if any(v.dest, proc (x: string): bool = x == conj) == true:
        conj_tbl[conj].src[k] = Low
    for k, v in conj_tbl.pairs:
      if any(v.dest, proc (x: string): bool = x == conj) == true:
        conj_tbl[conj].src[k] = Low
    tbl[conj] = conj_tbl[conj]

    if conj_tbl[conj].dest.contains("rx"):
      preModule = conj
      p2_conj_src = toSeq(conj_tbl[conj].src.keys)

  return (tbl, preModule, p2_conj_src)

when isMainModule:
  import std/cmdline
  if paramCount() > 0:
    var (tbl, rx_pre, rx_src) = parseData(readFile(paramStr(1)).strip())
    var q = initDeque[Pulse]()

    if rx_src.len == 0:
      raiseAssert("There is no conjunction module that outputs to the `rx` module.")
    var tmpTbl = initTable[string, seq[int]]()
    for s in rx_src:
      tmpTbl[s] = newSeq[int]()
    var rxChecker = RxChecker(modules: tmpTbl)
    let rxCheckSet = toHashSet(rx_src)

    var i = 0
    while true:
      inc(i)
      var pulse = Pulse(src: "button", dest: "broadcaster", level: Low)
      q.addLast(pulse)

      while q.len > 0:
        pulse = q.popFirst()

        if rxCheckSet.contains(pulse.src) and pulse.dest == rx_pre and pulse.level == High:
          var tmp = rxChecker.hit(pulse.src, i)
          if tmp.isSome:
            echo(lcm(tmp.get()))
            quit(QuitSuccess)

        if tbl.hasKey(pulse.dest) == false:
          continue
        for pulse in tbl[pulse.dest].input(pulse):
          q.addLast(pulse)
