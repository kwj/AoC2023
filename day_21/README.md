# Day 21

## Requirement

* [Julia](https://julialang.org/) (confirmed to work with Julia v1.9.4)

## How to use

### Read the source file in REPL

```console
julia> include("d21.jl")
```

### Run each solver with the name of the puzzle data file as an argument

*Part one*

```console
julia> d21_p1("input")
```

*Part two*

Note 1: This program only works well with the provided input data. It does not work with the sample map.

Note 2: It takes time to finish. (about 20 seconds on Raspberry Pi 4)

```console
julia> d21_p2("input")
```
