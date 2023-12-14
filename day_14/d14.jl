
module Day14

#=
  rounded rocks (O): 1
  cube-shaped rocks (#): -1
  empty space (.): 0
=#

function read_matrix(fname::AbstractString)
    data = map(split.(readlines(fname), "")) do lst
               map(lst) do ch
                   if ch == "O"
                       return 1
                   elseif ch == "#"
                       return -1
                   else
                       return 0
                   end
               end
           end
    stack(data)'
end

# Tilt the platform, matrix `m`, towards the smaller rows.
function tilt(m)
    for col in 1:size(m, 2)
        dst_idx = 1
        for src_idx in 1:size(m, 1)
            if m[src_idx, col] < 0
                dst_idx = src_idx + 1
                continue
            end
            if m[src_idx, col] == 1
                m[src_idx, col] = 0
                m[dst_idx, col] = 1
                dst_idx += 1
            end
        end
    end
    m
end

function eval_load(m)
    ans = 0
    for col in 1:size(m, 2)
        for (k, v) in pairs(reverse(m[:, col]))
            if v == 1
                ans += k
            end
        end
    end
    ans
end

function d14_p1(fname::String = "input")
    m = read_matrix(fname)
    eval_load(tilt(m))
end

#=
I met a hash collision!  I therefore use a hash value and a weight of
platform as dictionary's key.

> println("cnt: ", cnt, ", key: ", key)
>
> cnt: 108, key: (0x43ef4ace09e51995, 93240)
> cnt: 109, key: (0x88f04be144bf8203, 93239)
> cnt: 110, key: (0x05312ae46f75658c, 93226)
> cnt: 111, key: (0xa97697301f3e7aad, 93210)
> cnt: 112, key: (0xa97697301f3e7aad, 93196)
> cnt: 113, key: (0xf0e455314625ede3, 93180)
> cnt: 114, key: (0xa946da1f5bc7902a, 93154)

julia> for i in 1:100
         for j in 1:100
           if t111[i,j] != t112[i,j]
               println(i, ", ", j)
           end
         end
       end
37, 2
51, 16
=#

@inline do_cycle(m) = rotr90(tilt(rotr90(tilt(rotr90(tilt(rotr90(tilt(m))))))))

function d14_p2(fname::String = "input")
    limit = 1_000_000_000
    m = read_matrix(fname)
    tbl::Dict{Tuple{UInt, Int}, Int} = Dict()
    weight_lst = []
    ans = 0

    for cnt in 1:limit
        m = do_cycle(m)
        h = hash(m)
        w = eval_load(m)
        key = (h, w)
        if haskey(tbl, key)
            ans = weight_lst[tbl[key] + ((limit - cnt) % (cnt - tbl[key]))]
            break
        else
            tbl[key] = cnt
            push!(weight_lst, w)
        end
    end
    ans
end

end #module

using .Day14: d14_p1, d14_p2
