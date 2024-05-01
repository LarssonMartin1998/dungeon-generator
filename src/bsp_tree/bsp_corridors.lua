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

local function sort_rooms_by_distance_to_start(rooms)
    local map_start = { x = 1, y = 1 }
    table.sort(rooms, function(room1, room2)
        local distance1 = math.abs(room1.center.x - map_start.x) + math.abs(room1.center.y - map_start.y)
        local distance2 = math.abs(room2.center.x - map_start.x) + math.abs(room2.center.y - map_start.y)
        return distance1 < distance2
    end)
end

local is_adjacent_node_and_not_on_path = function(nodes, path, i, x, y)
    if i == 1 or i == #path then
        return false
    end

    if not nodes[y][x].is_passable then
        return false
    end

    local is_next_node = path[i].x == x and path[i].y == y
    if is_next_node then
        return false
    end

    return true
end

local function update_pathfinding_nodes_with_corridor(nodes, path)
    for i, section in ipairs(path) do
        nodes[section.y][section.x].is_passable = false
        for _, dir in ipairs(misc.directions) do
            local x = section.x + dir[1]
            local y = section.y + dir[2]
            if is_adjacent_node_and_not_on_path(nodes, path, i, x, y) then
                nodes[y][x].is_passable = false
            end
        end
    end
end

local function set_path_endpoint_as_passable(endpoint, pathfinding_nodes, is_passable)
    pathfinding_nodes[endpoint.y][endpoint.x].is_passable = is_passable
    -- All of the rooms have an extra tile around them that is blocked to avoid pathfinding licking the walls
    -- So we need to set that tile as passable as well
    pathfinding_nodes[endpoint.y + endpoint.direction[2]][endpoint.x + endpoint.direction[1]].is_passable = is_passable
end

local function calculate_possible_paths_between_rooms(room1, room2, width, height, pathfinding_nodes)
    local paths = {}

    for _, point1 in pairs(room1.perimeter) do
        if point1.is_free then
            for _, point2 in pairs(room2.perimeter) do
                if point2.is_free then
                    -- Need to set the both points, and the tile next to them as passable
                    -- So the pathfinding can find a path between them, remember to revert this after the path is found
                    set_path_endpoint_as_passable(point1, pathfinding_nodes, true)
                    set_path_endpoint_as_passable(point2, pathfinding_nodes, true)

                    local path = a_star.calculate_path(
                        pathfinding_nodes,
                        width,
                        height,
                        point1.x,
                        point1.y,
                        point2.x,
                        point2.y
                    )

                    set_path_endpoint_as_passable(point1, pathfinding_nodes, false)
                    set_path_endpoint_as_passable(point2, pathfinding_nodes, false)

                    if path then
                        table.insert(paths, path)
                    end
                end
            end
        end
    end

    return paths
end

local function get_shortest_path(paths)
    table.sort(paths, function(path1, path2)
        return #path1 < #path2
    end)

    return paths[1] or nil
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

local function connect_rooms_with_corridors(rooms, width, height, pathfinding_nodes)
    local corridors = {}
    for i = 1, #rooms - 1 do
        local room1 = rooms[i]
        local room2 = rooms[i + 1]

        local paths = calculate_possible_paths_between_rooms(room1, room2, width, height, pathfinding_nodes)
        local shortest_path = get_shortest_path(paths)

        if shortest_path then
            update_pathfinding_nodes_with_corridor(pathfinding_nodes, shortest_path)
            table.insert(corridors, shortest_path)
            create_door(room1, shortest_path[1])
            create_door(room2, shortest_path[#shortest_path])
        end
    end

    return corridors
end

function M.generate_corridors(rooms, map_config)
    local pathfinding_nodes = a_star.create_nodes(map_config.width, map_config.height)
    set_rooms_as_blocked_in_pathfinder(pathfinding_nodes, rooms, map_config.width, map_config.height)

    calculate_room_center(rooms)
    calculate_room_perimeters(rooms)
    sort_rooms_by_distance_to_start(rooms)

    return connect_rooms_with_corridors(rooms, map_config.width, map_config.height, pathfinding_nodes)
end

return M
