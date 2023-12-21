
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

function next_cands(m)
    res = zeros(Int64, size(m, 1), size(m, 2))
    x::Vector{Vector{Int64}} = []

    for v in collect.(Tuple.(findall(x -> x == 1, m)))
        push!(x, v + [1, 0])
        push!(x, v + [-1, 0])
        push!(x, v + [0, 1])
        push!(x, v + [0, -1])
    end
    for ind in CartesianIndex.(Tuple.(unique(filter(v -> 1 <= v[1] <= size(m, 1) && 1 <= v[2] <= size(m, 2), x))))
        res[ind] = 1
    end
    res
end

function d21_p1(fname::String = "input", max_steps::Int = 64)
    m = read_matrix(fname)
    starting_pos = findfirst(x -> x < 0, m)
    m[starting_pos] = 1

    w = zeros(Int64, size(m, 1), size(m, 2))
    w[starting_pos] = 1
    for i in 1:max_steps
        w = (&).(next_cands(w), m)
    end
    println(sum(w))
end

function get_num_tiles(m, ci, steps)
    w = zeros(Int, size(m, 1), size(m, 2))
    w[ci] = 1
    for i in 1:steps
        w = (&).(next_cands(w), m)
    end
    sum(w)
end

function get_num_tiles(m, ci, steps, small_cnt)
    w = zeros(Int, size(m, 1), size(m, 2))
    w[ci] = 1
    n_small = 0
    for i in 1:steps
        w = (&).(next_cands(w), m)
        if i == small_cnt
            n_small = sum(w)
        end
    end
    sum(w), n_small
end

function get_P(m, ci)
    w = zeros(Int, size(m, 1), size(m, 2))
    w[ci] = 1
    for i in 1:(65 + 64)
        w = (&).(next_cands(w), m)
    end
    p0 = sum(w)
    p1 = sum((&).(next_cands(w), m))

    p0, p1
end

function d21_p2(fname::String = "input", max_steps::Int = 26501365)
    m = read_matrix(fname)
    starting_pos = findfirst(x -> x < 0, m)
    m[starting_pos] = 1
    sx, sy = Tuple(starting_pos)

    # N, E, S, W
    n_N = get_num_tiles(m, CartesianIndex(size(m, 1), sy), 65 + 65)
    n_E = get_num_tiles(m, CartesianIndex(sx, 1), 65 + 65)
    n_S = get_num_tiles(m, CartesianIndex(1, sy), 65 + 65)
    n_W = get_num_tiles(m, CartesianIndex(sx, size(m,2)), 65 + 65)

    # NE, SE, SW, NW, n_ne, n_se, n_sw, n_nw
    n_NE, n_ne = get_num_tiles(m, CartesianIndex(size(m, 1), 1), 130 + 65, 64)
    n_SE, n_se = get_num_tiles(m, CartesianIndex(1, 1), 130 + 65, 64)
    n_SW, n_sw = get_num_tiles(m, CartesianIndex(1, size(m, 2)), 130 + 65, 64)
    n_NW, n_nw = get_num_tiles(m, CartesianIndex(size(m, 1), size(m, 2)), 130 + 65, 64)

    # P0, P1
    n_P0, n_P1 = get_P(m, starting_pos)

    n_cycles = div(max_steps - 65, 131 * 2)
    println(n_P0 * (2 * n_cycles - 1)^2 +
          n_P1 * (2 * n_cycles)^2 +
          (n_NE + n_SE + n_SW + n_NW) * (2 * n_cycles - 1) +
          (n_ne + n_se + n_sw + n_nw) * (2 * n_cycles) +
          (n_N + n_E + n_S + n_W))
end

end #module

using .Day21: d21_p1, d21_p2
