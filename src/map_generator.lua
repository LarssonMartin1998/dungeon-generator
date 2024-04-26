local bsp_handler = require("src.bsp_tree.bsp_handler")

local M = {}

M.characters = {
    wall = '#',
    floor = '.',
    door = '+',
}

function M.run()
    local width = 50
    local height = 50
    local depth = 8
    local min_size = 5
    bsp_handler.generate_with_bsp_trees(width, height, depth, min_size)
end

return M
