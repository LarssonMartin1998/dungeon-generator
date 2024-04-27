local bsp_leaves = require("src.bsp_tree.bsp_leaves")
local bsp_rooms = require("src.bsp_tree.bsp_rooms")
local bsp_corridors = require("src.bsp_tree.bsp_corridors")

local M = {}

function M.generate_with_bsp_trees(width, height, depth, leaf_min_size, room_padding, room_min_size)
    local leaf = bsp_leaves.generate_leaves(width, height, depth, leaf_min_size)
    local rooms = bsp_rooms.generate_rooms_from_leaves(leaf, width, height, room_padding, room_min_size)
    bsp_corridors.generate_corridors(rooms, width, height)
end

return M
