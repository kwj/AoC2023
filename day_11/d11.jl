
module Day11

function d11_p1(fname::String = "input")
    d11(fname, 2)
end

function d11_p2(fname::String = "input")
    d11(fname, 1_000_000)
end

function d11(fname::String, factor::Int)
    data = map(split.(readlines(fname), "")) do lst
               broadcast(lst) do node
                   if node == "." 0 else 1 end
               end
           end
    m = hcat(data...)
    r_empty = findall(r -> iszero(m[r, :]), 1:size(m, 1))
    c_empty = findall(c -> iszero(m[:, c]), 1:size(m, 2))
    galaxies = [[r, c] for r in 1:size(m, 1) for c in 1:size(m, 2) if m[r, c] == 1]

    ans = 0
    for i = 1:(length(galaxies) - 1)
        for j = (i + 1):length(galaxies)
            ans += distance(galaxies[i], galaxies[j], r_empty, c_empty, factor)
        end
    end

    ans
end

function distance(g1::Vector{Int}, g2::Vector{Int}, r_empty::Vector{Int}, c_empty::Vector{Int}, factor::Int)
    r_count = count(i -> i in range(min(g1[1], g2[1]), max(g1[1], g2[1])), r_empty)
    c_count = count(i -> i in range(min(g1[2], g2[2]), max(g1[2], g2[2])), c_empty)

    sum(map(abs, g1 - g2)) + (r_count + c_count) * (factor - 1)
end

end #module

using .Day11: d11_p1, d11_p2, d11
