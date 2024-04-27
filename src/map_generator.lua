local bsp_handler = require("src.bsp_tree.bsp_handler")

local M = {}

M.characters = {
    wall = '#',
    floor = '.',
    door = '+',
}

function M.run()
    local width = 60
    local height = 150
    local depth = 10
    local min_size = 10
    local room_padding = 2
    local room_min_size = 5

    bsp_handler.generate_with_bsp_trees(width, height, depth, min_size, room_padding, room_min_size)
end

return M
