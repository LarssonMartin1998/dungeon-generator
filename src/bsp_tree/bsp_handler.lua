local bsp_leaves = require("src.bsp_tree.bsp_leaves")
local bsp_rooms = require("src.bsp_tree.bsp_rooms")

local M = {}

function M.generate_with_bsp_trees(width, height, depth, min_size)
    local leaf = bsp_leaves.generate_leaves(width, height, depth, min_size)
    bsp_rooms.generate_rooms_from_leaves(leaf, width, height)
end

return M
