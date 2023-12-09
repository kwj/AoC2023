
module Day05

# Range(star, stop) = [start, stop]
# [Caution] It is not [start, stop). The `stop` is inclusive.
mutable struct Range
    start::Int64
    stop::Int64
end

# Example (from seed-to-soil map):
#   50 98 2   -->  RangeMap(98, 99, -48)
#   52 50 48  -->  RangeMap(50, 97, 2)
mutable struct RangeMap
    src_start::Int64
    src_stop::Int64
    delta::Int64
end

mutable struct CategoryMap
    dst_name::String
    mapping::Array{RangeMap}
end

# Make a transformation map which range is from 0 to max(Int64).
#
# Example
#   [RangeMap(50, 97, 2), RangeMap(98, 99, -48)]
#  -->
#   [RangeMap(0, 49, 0), RangeMap(50, 97, 2), RangeMap(98, 99, -48), RangeMap(100, 9223372036854775807, 0)]
function complement_rangemaps(r_maps::Array{RangeMap})
    tmp = sort(r_maps, by = x -> x.src_start)
    ret = Array{RangeMap}(undef, 0)

    prev = RangeMap(-1, -1, 0)
    for r_map in tmp
        if prev.src_stop + 1 < r_map.src_start
            push!(ret, RangeMap(prev.src_stop + 1, r_map.src_start - 1, 0))
        end
        push!(ret, r_map)
        prev = r_map
    end

    if ret[end].src_stop != typemax(Int64)
        push!(ret, RangeMap(ret[end].src_stop + 1, typemax(Int64), 0))
    end

    ret
end

function parse_file(fname::String)
    almanac = Dict{String, CategoryMap}()
    seeds = Array{Int64}(undef, 0)
    r_maps = Array{RangeMap}(undef, 0)
    s_name = ""
    d_name = ""

    for line in readlines(fname)
        if occursin(r"^seeds:", line) == true
            seeds = map(x -> parse(Int, x), split(line, " ")[2:end])
        elseif line == ""
            if isempty(r_maps) == false
                almanac[s_name] = CategoryMap(d_name, complement_rangemaps(r_maps))
            end
            empty!(r_maps)
        elseif occursin(r"map:", line) == true
            s_name, _, d_name = split(split(line, " ")[1], "-")
            empty!(r_maps)
        else
            d_start, s_start, size = map(x -> parse(Int, x), split(line, " "))
            push!(r_maps, RangeMap(s_start, s_start + size - 1, d_start - s_start))
        end
    end
    if isempty(r_maps) == false
        almanac[s_name] = CategoryMap(d_name, complement_rangemaps(r_maps))
    end

    seeds, almanac
end

function get_next_ranges(src_range::Range, r_maps::Array{RangeMap})
    next_r_maps = Iterators.takewhile(r -> src_range.stop >= r.src_start,
                                      Iterators.dropwhile(r -> src_range.start > r.src_stop, r_maps))
    collect(map(r_map -> Range(max(src_range.start, r_map.src_start) + r_map.delta,
                               min(src_range.stop, r_map.src_stop) + r_map.delta),
                next_r_maps))
end

function get_next_all_ranges(ranges::Array{Range}, c_map::CategoryMap)
    d_name = c_map.dst_name
    d_maps = c_map.mapping

    d_name, reduce(vcat, map(r -> get_next_ranges(r, d_maps), ranges))
end

function get_final_ranges(s_name::String, ranges::Array{Range}, final_name::String, almanac::Dict{String, CategoryMap})
    while true
        next_name, next_ranges = get_next_all_ranges(ranges, almanac[s_name])
        if next_name == final_name
            return next_ranges
        end
        s_name = next_name
        ranges = next_ranges
    end
end

function d05_p1(fname::String = "input")
    seeds, almanac = parse_file(fname)

    dst_ranges = reduce(vcat, (map(x -> get_final_ranges("seed", [Range(x, x)], "location", almanac), seeds)))
    minimum(map(r -> r.start, dst_ranges))
end

function d05_p2(fname::String = "input")
    seeds_info, almanac = parse_file(fname)
    seeds = map(x -> Range(x[1], x[1] + x[2] - 1), Iterators.partition(seeds_info, 2))

    dst_ranges = reduce(vcat, (map(seed_range -> get_final_ranges("seed", [seed_range], "location", almanac), seeds)))
    minimum(map(r -> r.start, dst_ranges))
end

end #module

using .Day05: d05_p1, d05_p2
