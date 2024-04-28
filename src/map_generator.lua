local bsp_handler = require("src.bsp_tree.bsp_handler")

local M = {}

M.characters = {
    wall = '#',
    floor = '.',
    door = '+',
}

function M.run()
    local width = 200
    local height = 50
    local depth = 3
    local min_size = 20
    local room_padding = 4
    local room_min_size = 10

    bsp_handler.generate_with_bsp_trees(width, height, depth, min_size, room_padding, room_min_size)
end

return M
