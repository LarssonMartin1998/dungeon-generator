local a_star = require("src.pathfinding.a_star")
local mathutil = require("src.utility.math")

local M = {}

local function calculate_room_center(rooms)
    for _, room in ipairs(rooms) do
        room.center = {
            x = math.floor(room.x + room.width * 0.5),
            y = math.floor(room.y + room.height * 0.5)
        }
    end
end

local function calculate_edges(rooms)
    local edges = {}
    for i = 1, #rooms do
        for j = i + 1, #rooms do
            local distance = mathutil.get_manhattan_distance(
                rooms[i].center.x,
                rooms[i].center.y,
                rooms[j].center.x,
                rooms[j].center.y)

            table.insert(edges, {
                distance = distance,
                room1 = rooms[i],
                room2 = rooms[j]
            })
        end
    end

    return edges
end

local function set_rooms_as_blocked_in_pathfinder(nodes, rooms)
    for _, room in ipairs(room) do
    end
end

local function debug_init_map(width, height)
    local map = {}

    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            map[y][x] = " "
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

local function debug_add_edges_to_map(edges, map)
    for _, edge in ipairs(edges) do
        local room1_center = edge.room1.center
        local room2_center = edge.room2.center

        -- Determine the horizontal and vertical order of the rooms
        local x_start, x_end = room1_center.x, room2_center.x
        local y_start, y_end = room1_center.y, room2_center.y

        local x_char = ">"
        if x_start > x_end then
            x_start, x_end = x_end, x_start -- swap to ensure left to right drawing
            x_char = "<"
        end

        local y_char = "^"
        if y_start > y_end then
            y_start, y_end = y_end, y_start -- swap to ensure top to bottom drawing
            y_char = "v"
        end

        for x = x_start, x_end do
            local y = room1_center.y
            map[y][x] = x_char
        end
        for y = y_start, y_end do
            local x = room2_center.x
            map[y][x] = y_char
        end
    end
end

function M.generate_corridors(rooms, width, height)
    local pathfinding_nodes = a_star.create_nodes(width, height)
    calculate_room_center(rooms)
    local edges = calculate_edges(rooms)

    -- local map = debug_init_map(width, height)
    -- debug_add_rooms_to_map(rooms, map)
    -- debug_add_edges_to_map(edges, map)
    -- debug_draw_map(map, width, height)
end

return M
