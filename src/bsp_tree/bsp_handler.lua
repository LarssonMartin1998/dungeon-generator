local leaves = require("src.bsp_tree.bsp_leaves")

local M = {}

local function debug_init_map(width, height)
    local map = {}

    for x = 1, width do
        map[x] = {}
        for y = 1, height do
            map[x][y] = " "
        end
    end

    return map
end

local function is_end_leaf(leaf)
    return leaf.children == nil
end

local function debug_add_leaf_splits_to_map(leaf, map, width, height, level)
    if is_end_leaf(leaf) then
        for x = 1, width do
            if x >= leaf.x and x < leaf.x + leaf.width then
                for y = 1, height do
                    if y >= leaf.y and y < leaf.y + leaf.height then
                        map[x][y] = level
                    end
                end
            end
        end

        return
    end

    for _, child in ipairs(leaf.children) do
        debug_add_leaf_splits_to_map(child, map, width, height, level + 1)
    end
end

local function debug_draw_map(map, width, height)
    for x = 1, width do
        local row = ""
        for y = 1, height do
            row = row .. map[x][y]
        end
        print(row)
    end
end

function M.generate_with_bsp_trees(width, height, depth, min_size)
    local leaf = leaves.generate_leaves(width, height, depth, min_size)
    local map = debug_init_map(width, height)
    debug_add_leaf_splits_to_map(leaf, map, width, height, 1)
    debug_draw_map(map, width, height)
end

return M
