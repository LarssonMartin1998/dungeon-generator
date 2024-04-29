local M = {}

local function is_end_leaf(leaf)
    return leaf.children == nil
end

local function populate_end_leaves_recursive(end_leaves, leaf)
    if is_end_leaf(leaf) then
        table.insert(end_leaves, leaf)
        return
    end

    for _, child in ipairs(leaf.children) do
        populate_end_leaves_recursive(end_leaves, child)
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

function M.generate_rooms_from_leaves(root_leaf, rooms_config)
    local end_leaves = {}
    populate_end_leaves_recursive(end_leaves, root_leaf)

    return generate_rooms(end_leaves, rooms_config.padding, rooms_config.min_size)
end

return M
