
module Day24

function read_data(fname::AbstractString)
    function parse_line(line)
        ns = map(x -> parse(Int, x), split(line, r"[^\d-]+"))

        # (x, y, z), (dx, dy, dz)
        Tuple(ns[1:3]), Tuple(ns[4:6])
    end

    parse_line.(readlines(fname))
end

function d24_p1(fname::String = "input"; MIN = 2 * 10^14, MAX = 4 * 10^14)
    function within(x, y)
        MIN <= x <= MAX && MIN <= y <= MAX
    end

    hailstones = read_data(fname)

    cnt = 0
    for j in 1:length(hailstones)
        for k in (j + 1):length(hailstones)
            (x_j, y_j, _), (dx_j, dy_j, _) = hailstones[j]
            (x_k, y_k, _), (dx_k, dy_k, _) = hailstones[k]

            # slope
            m_j = dy_j / dx_j
            m_k = dy_k / dx_k

            # If both slopes aren't equal, the two lines intersect.
            # Otherwise, the two lines are parallel or identical.
            if m_j != m_k
                x = ((y_k - m_k * x_k) - (y_j - m_j * x_j)) / (m_j - m_k)
                y = m_j * x + (y_j - m_j * x_j)

                t_j = (x - x_j) / dx_j
                t_k = (x - x_k) / dx_k

                if within(x, y) == true && t_j > 0 && t_k > 0
                    cnt += 1
                end
            else
                # linear equation: Y = aX + b  (a: slope (not 0), b: constant value on y-axis)
                #     --> b = Y - aX
                # If the two lines are identical, check on the collision of the two hailstones or not.
                if y_j - m_j * x_j == y_k - m_k * x_k
                    t = (x_k - x_j) / (dx_j - dx_k)
                    if t > 0 && within(x_j + t * dx_j, y_j + t * dx_j)
                        cnt += 1
                    end
                end
            end
        end
    end

    cnt
end

# Rock: (R_x, R_y, R_z) + t * (R_dx, R_dy, R_dz)
# Hailstones: (H[i]_x, H[i]_y, H[i]_z) + t * (H[i]_dx, H[i]_dy, H[i]_dz)
#
# Think of this problem like a geocentric model. The rock is the origin of three-dimensional
# space and We sit on it. From the rock view, hailstones move as follows.
#
#   (H[i]_x - R_x, H[i]_y - R_y, H[i]_z - R_z) + t * (H[i]_dx - R_dx, H[i]_dy - R_dy, H[i]_dz - R_dz)
#
# Every hailstone comes in a straight line toward the rock, the *origin*. So, the cross
# product of hailstone's position vector and movement velocity vector is equal to 0.
# For simplicity, we think moves in X-Y plane. Since the cross product is equal to 0:
#
#   (H[i]_x - R_x) * (H[i]_dy - R_dy) - (H[i]_y - R_y) * (H[i]_d - R_dx) = 0
#
#   Hailstone H1:
#     (H1_x - R_x) * (H1_dy - R_dy) - (H1_y - R_y) * (H1_dx - R_dx) = 0
#   Hailstone H2:
#     (H2_x - R_x) * (H2_dy - R_dy) - (H2_y - R_y) * (H2_dx - R_dx) = 0
#
# Subtarct above equations
#
#   (H1_x * H1_dy- H2_x * H2_dy) - R_dy * (H1_x - H2_x) - R_x * (H1_dy - H2_dy) -
#      (H1_y * H1_dx - H2_y * H2_dx) + R_dx * (H1_y + H2_y) + R_y * (H1_dx - H2_dx) = 0
#  -->
#   R_x * (-(H1_dy - H2_dy)) + R_y * (H1_dx - H2_dx) + R_dx * (H1_y - H2_y) + R_dy * (-(H1_x - H2_x))
#     = (H1_y * H1_dx - H2_y * H2_dx) - (H1_x * H1_dy- H2_x * H2_dy)
#
# This is a linear equation in four variables (R_x, R_y, R_dx, R_dy).
# We therefore create four equations and solve.

function d24_p2(fname::String = "input")
    hailstones = read_data(fname)
    (px0, py0, _), (vx0, vy0, _) = hailstones[1]
    data = map(hailstones[2:5]) do stone
               (px, py, _), (vx, vy, _) = stone
               [-(vy0 - vy), vx0 - vx, py0 - py, -(px0 - px)], (py0 * vx0 - py * vx) - (px0 * vy0 - px * vy)
           end

    A = transpose(hcat(getindex.(data, 1)...))
    b = getindex.(data, 2)

    (Rx, Ry, Rdx, Rdy) = Int.(round.(A \ b))

    (H1x, _, H1z), (H1dx, _, H1dz) = hailstones[1]
    (H2x, _, H2z), (H2dx, _, H2dz) = hailstones[2]

    # Rx + t1 * Rdx = H1x + t1 * H1dx
    #   --> t1 = (Rx - H1x) / (H1dx - Rdx)
    t1 = (Rx - H1x) / (H1dx - Rdx)
    t2 = (Rx - H2x) / (H2dx - Rdx)

    # (H1z + t1 * H1dz) - (H2z + t2 * H2dz) = (t1 - t2) * Rdz
    Rdz = ((H1z + t1 * H1dz) - (H2z + t2 * H2dz)) / (t1 - t2)

    # Rz + t1 * Rdz = H1z + t1 * H1dz
    Rz = H1z + t1 * (H1dz - Rdz)

    Int(Rx + Ry + Rz)
end

end #module

using .Day24: d24_p1, d24_p2
