
module Day21

#=
  garden plots (.): 1
  rocks (#): 0
  starting position (S): -1
=#

function read_matrix(fname::AbstractString)
    data = map(split.(readlines(fname), "")) do lst
               map(lst) do ch
                   if ch == "."
                       return 1
                   elseif ch == "#"
                       return 0
                   else
                       return -1
                   end
               end
           end
    stack(data)'
end

function d21_p1(fname::String = "input")
    M = read_matrix(fname)
    starting_pos = findfirst(x -> x < 0, M)
    M[starting_pos] = 1

    W = zeros(Int, size(M))
    W[starting_pos] = 1

    cnt = Int[]
    for i in 1:64
        W = reduce(.|, circshift.([W], [(1, 0), (-1, 0), (0, 1), (0, -1)])) .& M
    end
    sum(W)
end

#=
Part 2:

This problem is a calculation of an area of some kind.

The map data given in this problem, like the sample data, the edges are all empty.
On the ohter hand, the row and column of the starting point `S` are also empty.

And then, the size of the map is 131x131 and 26501365 = 131 * 202300 + 65. I therefore
complement the answer with polynomial interpolation from the following three data points.

  - 65 steps
  - 65 + 131 steps
  - 65 + 131 * 2 steps

  Polynomial interpolation
  https://en.wikipedia.org/wiki/Polynomial_interpolation

Note:
  The quadratic equation can be used in this problem because it is a calculation
  of the area that spreads over with a certain cycle.
=#

function d21_p2(fname::String = "input")
    m = read_matrix(fname)
    starting_pos = findfirst(x -> x < 0, m)
    m[starting_pos] = 1

    # Since the map is a square with an *odd* number of side length, there is no problem
    # for the calculation of the (65 + 131*2) steps with the (131*3) * (131*3) map.
    M = repeat(m, 3, 3)
    W = zeros(Int, size(M))
    W[starting_pos] = 1

    cnt = Int[]
    for i in 1:(65 + 131 * 2)
        W = reduce(.|, circshift.([W], [(1, 0), (-1, 0), (0, 1), (0, -1)])) .& M
        if (i - 65) % 131 == 0
            push!(cnt, sum(W))
        end
    end

    # f(x) = a1 + a2*x + a3*x^2
    #
    # x = 0 (after 65 + 131 * 0 steps), f(0) = cnt[1]
    # x = 1 (after 65 + 131 * 1 steps), f(1) = cnt[2]
    # x = 2 (after 65 + 131 * 2 steps), f(2) = cnt[3]

    # vandermode matrix for x=0:2
    V = [0, 1, 2] .^ transpose([0, 1, 2])

    # Va = cnt
    #  --> a = inv(V) * cnt
    a = inv(V) * cnt

    # 26501365 steps = 65 + 131 * 202300 steps
    # so, the answer is f(202300) = a1 * 202300^0 + a2 * 202300^1 + a3 * 202300^2.
    Int(transpose(202300 .^ (0:2)) * a)
end

end #module

using .Day21: d21_p1, d21_p2
