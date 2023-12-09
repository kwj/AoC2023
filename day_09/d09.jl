
module Day09

function calc_pred(lst)
    lst[end] + ((length(lst) == 1) ? 0 : calc_pred((@view lst[begin+1:end]) - (@view lst[begin:end-1])))
end

function d09_p1(fname::String = "input")
    data = map(line -> map(x -> parse(Int, x), split(line, " ")), readlines(fname))
    sum(map(lst -> calc_pred(lst), data))
end

function d09_p2(fname::String = "input")
    data = map(line -> map(x -> parse(Int, x), reverse(split(line, " "))), readlines(fname))
    sum(map(lst -> calc_pred(lst), data))
end

end #module

using .Day09: d09_p1, d09_p2
export d09_p1, d09_p2
