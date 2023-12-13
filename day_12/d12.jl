
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
  [pos]
    * a position in the row
       s = "..??#???##??#??"
                ^
             pos = 5
  [grp_idx]
    * index of broken spring group under checking
  [consec_num]
    * number of consecutive broken springs in a group under checking
       If the specified number of consecutive broken springs are found,
       increase `grp_idx` by one and set `not_broken`, the broken spring
       prohibition flag, is 1 for the next position.
  [not_broken]
    * prohibition of broken spring
       If this flag is set (1), the condition of spring at the position
       must be `operational` or `unknown`.
       This flag is set only immediately after found a specified consecutive
       damaged springs.
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
            elseif (s[pos] == '#' || s[pos] == '?') && grp_idx <= grp_len && not_broken == 0
                if s[pos] == '?' && consec_num == 0
                    # Treat this `unknown` spring as `operational`,
                    # so divide a ghost into two.
                    next_key = [pos + 1, grp_idx, 0, 0]
                    next_st[next_key] = get(next_st, next_key, 0) + v
                end

                # The following is the process for damaged spring
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
