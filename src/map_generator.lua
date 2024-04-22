local bsp_tree = require("src.bsp_tree")

local M = {}

M.characters = {
    wall = '#',
    floor = '.',
    door = '+',
}

local function draw_map(map)
    for y = 1, #map do
        local row = map[y]
        local row_string = ""

        for x = 1, #row do
            local cell = row[x]

            row_string = row_string .. cell
        end

        print(row_string)
    end
end

function M.run()
    local map = bsp_tree.generate_with_bsp_trees()

    draw_map(map)
end

return M
