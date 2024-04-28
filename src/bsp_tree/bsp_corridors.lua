local a_star = require("src.pathfinding.a_star")
local misc = require("src.utility.misc")

local M = {}

local function calculate_room_center(rooms)
    for _, room in ipairs(rooms) do
        room.center = {
            x = room.x + math.floor(room.width * 0.5),
            y = room.y + math.floor(room.height * 0.5)
        }
    end
end

local function create_perimeter_dir(x, y, direction)
    return {
        x = x,
        y = y,
        direction = direction,
        is_free = true
    }
end

local function calculate_room_perimeters(rooms)
    local padding = 1
    for _, room in ipairs(rooms) do
        local rand_top = math.random(room.x + padding, room.x + room.width - padding)
        local rand_right = math.random(room.y + padding, room.y + room.height - padding)
        local rand_bottom = math.random(room.x + padding, room.x + room.width - padding)
        local rand_left = math.random(room.y + padding, room.y + room.height - padding)

        room.perimeter = {
            top = create_perimeter_dir(rand_top, room.y, misc.directions[1]),
            right = create_perimeter_dir(room.x + room.width, rand_right, misc.directions[2]),
            bottom = create_perimeter_dir(rand_bottom, room.y + room.height, misc.directions[3]),
            left = create_perimeter_dir(room.x, rand_left, misc.directions[4]),
        }
    end
end

local function set_rooms_as_blocked_in_pathfinder(nodes, rooms, width, height)
    for _, room in ipairs(rooms) do
        -- Set one tile around the room as blocked so the pathfinding doesnt lick the walls
        for y = math.max(1, room.y - 1), math.min(height, room.y + room.height + 1) do
            for x = math.max(1, room.x - 1), math.min(width, room.x + room.width + 1) do
                nodes[y][x].is_passable = false
            end
        end
    end
end

local function debug_init_map(width, height)
    local map = {}

    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            if x == 1 or x == width or y == 1 or y == height then
                map[y][x] = "@"
            else
                map[y][x] = " "
            end
        end
    end

    return map
end

local function debug_draw_map(map, width, height)
    for y = 1, height do
        local line = ""
        for x = 1, width do
            line = line .. map[y][x]
        end
        print(line)
    end
end

local function is_edge(x, y, room)
    return x == room.x or x == room.x + room.width or y == room.y or y == room.y + room.height
end

local function debug_add_rooms_to_map(rooms, map)
    for _, room in ipairs(rooms) do
        for y = room.y, room.y + room.height do
            for x = room.x, room.x + room.width do
                if is_edge(x, y, room) then
                    map[y][x] = "#"
                else
                    map[y][x] = "."
                end
            end
        end
    end
end

local function debug_add_corridors_to_map(corridors, map)
    for _, corridor in ipairs(corridors) do
        for _, node in ipairs(corridor) do
            map[node.y][node.x] = "."
        end
    end
end

local function update_pathfinding_nodes_with_corridor(nodes, path)
    if not path then
        return false
    end

    for _, section in ipairs(path) do
        nodes[section.y][section.x].is_passable = false
    end

    return true
end

local function find_closest_perimeter_points(room1, room2)
    local closest_distance = math.huge
    local closest_point1 = nil
    local closest_point2 = nil

    for _, point1 in pairs(room1.perimeter) do
        for _, point2 in pairs(room2.perimeter) do
            if point1.is_free and point2.is_free then
                local distance = math.abs(point1.x - point2.x) + math.abs(point1.y - point2.y)
                if distance < closest_distance then
                    closest_distance = distance
                    closest_point1 = point1
                    closest_point2 = point2
                end
            end
        end
    end

    if closest_point1 and closest_point2 then
        closest_point1.is_free = false
        closest_point2.is_free = false
    end

    return closest_point1, closest_point2
end

local function set_door_passable(room, door, pathfinding_nodes, is_passable)
    pathfinding_nodes[door.y][door.x].is_passable = is_passable
    pathfinding_nodes[door.y + door.direction[2]][door.x + door.direction[1]].is_passable = is_passable
end

local function create_door(room, point)
    if not room.doors then
        room.doors = {}
    end

    table.insert(room.doors, {
        x = point.x,
        y = point.y
    })
end

local function create_corridor_from_path(start, goal, width, height, pathfinding_nodes, corridors)
    local path = a_star.calculate_path(
        pathfinding_nodes,
        width,
        height,
        start.x,
        start.y,
        goal.x,
        goal.y
    )

    if not update_pathfinding_nodes_with_corridor(pathfinding_nodes, path) then
        return false
    end

    table.insert(corridors, path)
    return true
end

local function connect_rooms_with_corridors(rooms, width, height, pathfinding_nodes)
    local map_start = { x = 1, y = 1 }
    table.sort(rooms, function(room1, room2)
        local distance1 = math.abs(room1.center.x - map_start.x) + math.abs(room1.center.y - map_start.y)
        local distance2 = math.abs(room2.center.x - map_start.x) + math.abs(room2.center.y - map_start.y)
        return distance1 < distance2
    end)

    local corridors = {}
    for i = 1, #rooms - 1 do
        local room1 = rooms[i]
        local is_last_room = i == #rooms
        local room2 = rooms[i + 1]

        local start, goal = find_closest_perimeter_points(room1, room2)
        set_door_passable(room1, start, pathfinding_nodes, true)
        set_door_passable(room2, goal, pathfinding_nodes, true)

        if not create_corridor_from_path(start, goal, width, height, pathfinding_nodes, corridors) then
            set_door_passable(room1, start, pathfinding_nodes, false)
            set_door_passable(room2, goal, pathfinding_nodes, false)
        else
            create_door(room1, start)
            create_door(room2, goal)
        end
    end

    return corridors
end

function M.generate_corridors(rooms, width, height)
    local pathfinding_nodes = a_star.create_nodes(width, height)
    set_rooms_as_blocked_in_pathfinder(pathfinding_nodes, rooms, width, height)

    calculate_room_center(rooms)
    calculate_room_perimeters(rooms)

    local corridors = connect_rooms_with_corridors(rooms, width, height, pathfinding_nodes)

    local map = debug_init_map(width, height)
    debug_add_rooms_to_map(rooms, map)
    debug_add_corridors_to_map(corridors, map)

    debug_draw_map(map, width, height)
end

return M
