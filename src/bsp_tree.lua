local M = {}

function M.generate_with_bsp_trees()
    local map = {}

    for y = 1, 10 do
        local row = {}

        for x = 1, 10 do
            table.insert(row, ".")
        end

        table.insert(map, row)
    end

    return map
end

return M
