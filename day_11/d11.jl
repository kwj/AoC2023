
module Day11

function d11_p1(fname::String = "input")
    d11(fname, 2)
end

function d11_p2(fname::String = "input")
    d11(fname, 1_000_000)
end

function d11(fname::String, factor::Int)
    data = map(split.(readlines(fname), "")) do line_lst
               broadcast(line_lst) do elm
                   if elm == "." 0 else 1 end
               end
           end
    m = stack(data)
    x_gaps = findall(x -> iszero(m[x, :]), 1:size(m, 1))
    y_gaps = findall(y -> iszero(m[:, y]), 1:size(m, 2))
    galaxies = [[x, y] for x in 1:size(m, 1) for y in 1:size(m, 2) if m[x, y] == 1]

    ans = 0
    for i = 1:(length(galaxies) - 1)
        for j = (i + 1):length(galaxies)
            ans += manhattan_distance(galaxies[i], galaxies[j], x_gaps, y_gaps, factor)
        end
    end

    ans
end

function manhattan_distance(g1::Vector{Int}, g2::Vector{Int}, x_gaps::Vector{Int}, y_gaps::Vector{Int}, factor::Int)
    x_count = count(i -> i in range(min(g1[1], g2[1]), max(g1[1], g2[1])), x_gaps)
    y_count = count(i -> i in range(min(g1[2], g2[2]), max(g1[2], g2[2])), y_gaps)

    sum(abs.(g1 - g2)) + (x_count + y_count) * (factor - 1)
end

end #module

using .Day11: d11_p1, d11_p2, d11
