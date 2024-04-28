local M = {}

function M.get_manhattan_distance(x1, y1, x2, y2)
    local x_delta = math.abs(x1 - x2)
    local y_delta = math.abs(y1 - y2)
    return x_delta + y_delta
end

return M
