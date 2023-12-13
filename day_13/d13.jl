
module Day13

function d13(fname::String = "input")
    data = map_to_matrix.(split(chomp(read(fname, String)), "\n\n"))

    r1_set = Set()
    for (idx, m) in pairs(data)
        for row in find_horiz_reflections(m, 0)
            push!(r1_set, (idx, row))
        end
    end

    c1_set = Set()
    for (idx, m) in pairs(data)
        for col in find_horiz_reflections(m', 0)
            push!(c1_set, (idx, col))
        end
    end

    ans1 = 100 * reduce((acc, x) -> acc + x[2], r1_set; init = 0) +
           reduce((acc, x) -> acc + x[2], c1_set; init = 0)
    println("Part one: ", ans1)


    r2_set = Set()
    for (idx, m) in pairs(data)
        for row in find_horiz_reflections(m, 1)
            push!(r2_set, (idx, row))
        end
    end

    c2_set = Set()
    for (idx, m) in pairs(data)
        for col in find_horiz_reflections(m', 1)
            push!(c2_set, (idx, col))
        end
    end

    ans2 = 100 * reduce((acc, x) -> acc + x[2], setdiff(r2_set, r1_set); init = 0) +
           reduce((acc, x) -> acc + x[2], setdiff(c2_set, c1_set); init = 0)
    println("Part two: ", ans2)
end

function map_to_matrix(s)
    data = map(split.(split(s, "\n"), "")) do line_lst
               broadcast(line_lst) do elm
                   if elm == "." 0 else 1 end
               end
           end
    m = hcat(data...)
    transpose(m)
end

function find_horiz_reflections(m, smudge)
    n_rows = size(m, 1)
    res = []
    for idx in 1:(n_rows - 1)
        if sum(abs.(m[idx, :] - m[idx + 1, :])) > smudge
            continue
        end

        width = min(n_rows - idx, idx)
        if sum(abs.(m[idx:-1:(idx - width + 1), :] - m[(idx + 1):(idx + width), :])) <= smudge
            push!(res, idx)
        end
    end
    res
end

end #module

using .Day13: d13
