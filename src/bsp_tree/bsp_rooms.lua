local M = {}


function decimal_to_base(input)
    local num = tonumber(input)
    if not num then
        return input
    end

    if num < 0 then
        error("Number must be non-negative")
    end

    local chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local base = #chars -- 62
    if num == 0 then
        return "0"
    end

    local result = ""
    while num > 0 do
        local index = (num % base) + 1
        result = chars:sub(index, index) .. result
        num = math.floor(num / base)
    end

    return result
end

local function is_end_leaf(leaf)
    return leaf.children == nil
end

local function populate_end_leaves(end_leaves, leaf)
    if is_end_leaf(leaf) then
        table.insert(end_leaves, leaf)
        return
    end

    for _, child in ipairs(leaf.children) do
        populate_end_leaves(end_leaves, child)
    end
end

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

local function debug_add_leaves_to_map(leaves, map, width, height)
    for i, leaf in ipairs(leaves) do
        for x = 1, width do
            if x >= leaf.x and x < leaf.x + leaf.width then
                for y = 1, height do
                    if y >= leaf.y and y < leaf.y + leaf.height then
                        map[x][y] = i
                    end
                end
            end
        end
    end
end

local function debug_draw_map(map, width, height)
    for x = 1, width do
        local line = ""
        for y = 1, height do
            line = line .. decimal_to_base(map[x][y])
        end
        print(line)
    end
end

function M.generate_rooms_from_leaves(root_leaf, width, height)
    local end_leaves = {}
    populate_end_leaves(end_leaves, root_leaf)

    local map = debug_init_map(width, height)
    debug_add_leaves_to_map(end_leaves, map, width, height)
    debug_draw_map(map, width, height)
end

return M
