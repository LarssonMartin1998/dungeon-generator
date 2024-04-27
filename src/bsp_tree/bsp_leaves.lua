local M = {}

local function should_split_leaf(depth, leaf, min_size)
    local double_min_size = min_size * 2
    local room_for_two_leaves = leaf.width > double_min_size or leaf.height > double_min_size
    return depth > 0 and room_for_two_leaves
end

local function should_split_vertically(leaf)
    if leaf.width > leaf.height then
        return true
    elseif leaf.height > leaf.width then
        return false
    else
        return math.random() > 0.5
    end
end

local function split_axis(axis, min_size)
    local first = math.random(min_size, axis - min_size)
    local second = axis - first
    return first, second
end

local function create_leaf(width, height, x, y)
    return {
        width = width,
        height = height,
        x = x,
        y = y
    }
end

local function split_leaf_recursive(leaf, depth, min_size)
    if not should_split_leaf(depth, leaf, min_size) then
        return
    end

    if should_split_vertically(leaf) then
        local left_width, right_width = split_axis(leaf.width, min_size)
        leaf.children = {
            create_leaf(left_width, leaf.height, leaf.x, leaf.y),
            create_leaf(right_width, leaf.height, leaf.x + left_width, leaf.y)
        }
    else
        local top_height, bottom_height = split_axis(leaf.height, min_size)
        leaf.children = {
            create_leaf(leaf.width, top_height, leaf.x, leaf.y),
            create_leaf(leaf.width, bottom_height, leaf.x, leaf.y + top_height)
        }
    end

    for _, child_leaf in ipairs(leaf.children) do
        split_leaf_recursive(child_leaf, depth - 1, min_size)
    end
end

function M.generate_leaves(width, height, depth, min_size)
    local root_leaf = create_leaf(width, height, 0, 0)
    split_leaf_recursive(root_leaf, depth, min_size)
    return root_leaf
end

return M
