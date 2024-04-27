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

local function create_room(width, height, x, y)
    return {
        width = width,
        height = height,
        x = x,
        y = y
    }
end

local function generate_room_size(leaf, padding, min_size)
    local room_width = math.random(min_size, leaf.width - padding * 2)
    local room_height = math.random(min_size, leaf.height - padding * 2)
    return room_width, room_height
end

local function generate_room_position(leaf, padding, room_width, room_height)
    local room_x = math.random(leaf.x + padding, leaf.x + leaf.width - room_width - padding)
    local room_y = math.random(leaf.y + padding, leaf.y + leaf.height - room_height - padding)
    return room_x, room_y
end

local function generate_rooms(end_leaves, padding, min_size)
    local rooms = {}

    for _, leaf in ipairs(end_leaves) do
        local room_width, room_height = generate_room_size(leaf, padding, min_size)
        local room_x, room_y = generate_room_position(leaf, padding, room_width, room_height)
        local new_room = create_room(room_width, room_height, room_x, room_y)

        table.insert(rooms, new_room)
    end
    return rooms
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

local function debug_add_rooms_to_map(rooms, map, width, height)
    for i, room in ipairs(rooms) do
        for x = 1, width do
            if x >= room.x and x < room.x + room.width then
                for y = 1, height do
                    if y >= room.y and y < room.y + room.height then
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

function M.generate_rooms_from_leaves(root_leaf, width, height, padding, min_size)
    local end_leaves = {}
    populate_end_leaves(end_leaves, root_leaf)

    local rooms = generate_rooms(end_leaves, padding, min_size)

    local map = debug_init_map(width, height)
    debug_add_rooms_to_map(rooms, map, width, height)
    debug_draw_map(map, width, height)
end

return M
