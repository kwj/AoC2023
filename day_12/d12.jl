
module Day12

function d12_p1(fname::String)
    data = map(split.(readlines(fname), " ")) do v
               [v[1], map(x -> parse(Int, x), split(v[2], ","))]
           end
    ans = 0
    for (s, grp) in data
        ans += solve(s, grp)
    end
    ans
end

function d12_p2(fname::String)
    data = map(split.(readlines(fname), " ")) do v
               [join(repeat([v[1]], 5), "?"), repeat(map(x -> parse(Int, x), split(v[2], ",")), 5)]
           end
    ans = 0
    for (s, grp) in data
        ans += solve(s, grp)
    end
    ans
end

#=
Each ghost has own state.
  1) a position in the row (pos)
  2) number of broken spring group being checked (grp_idx)
  3) number of consecutive broken springs in a group (consec_num)
  4) permission of broken spring (not_broken)

[example]

  s = "..??#???##??#??"
           ^
       `pos` = 5

=#
function solve(s::AbstractString, grp::Vector{Int64})
    s_len = length(s)
    grp_len = length(grp)

    ans = 0
    crnt_st::Dict{Vector{Int64}, Int64} = Dict([([1, 1, 0, 0], 1)])
    while length(crnt_st) > 0
        next_st::Dict{Vector{Int64}, Int64} = Dict()
        for ((pos, grp_idx, consec_num, not_broken), v) in crnt_st
            if pos > s_len
                if grp_idx > grp_len
                    ans += v
                end
                continue
            elseif (s[pos] == '#' || s[pos] == '?') && grp_idx <= grp_len && not_broken == 0
                if s[pos] == '?' && consec_num == 0
                    next_key = [pos + 1, grp_idx, consec_num, 0]
                    next_st[next_key] = get(next_st, next_key, 0) + v
                end
                consec_num += 1
                if consec_num == grp[grp_idx]
                    next_key = [pos + 1, grp_idx + 1, 0, 1]
                else
                    next_key = [pos + 1, grp_idx, consec_num, 0]
                end
                next_st[next_key] = get(next_st, next_key, 0) + v
            elseif (s[pos] == '.' || s[pos] == '?') && consec_num == 0
                next_key = [pos + 1, grp_idx, 0, 0]
                next_st[next_key] = get(next_st, next_key, 0) + v
            end
        end
        crnt_st = next_st
    end
    ans
end

end #module

using .Day12: d12_p1, d12_p2
