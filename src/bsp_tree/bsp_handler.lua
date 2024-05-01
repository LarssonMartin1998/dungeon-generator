local bsp_leaves = require("src.bsp_tree.bsp_leaves")
local bsp_rooms = require("src.bsp_tree.bsp_rooms")
local bsp_corridors = require("src.bsp_tree.bsp_corridors")

local misc = require("src.utility.misc")

local M = {}

local function is_edge(x, y, room)
    return x == room.x or x == room.x + room.width or y == room.y or y == room.y + room.height
end

local function add_rooms_to_map(rooms, map)
    for _, room in ipairs(rooms) do
        for y = room.y, room.y + room.height do
            for x = room.x, room.x + room.width do
                if is_edge(x, y, room) then
                    map[y][x] = misc.map_char.wall
                else
                    map[y][x] = misc.map_char.floor
                end
            end
        end
    end
end

local function add_corridors_to_map(corridors, map)
    for _, corridor in ipairs(corridors) do
        for _, node in ipairs(corridor.path) do
            map[node.y][node.x] = misc.map_char.floor
            for _, dir in ipairs(misc.directions) do
                local x = node.x + dir[1]
                local y = node.y + dir[2]
                if map[y][x] == misc.map_char.empty then
                    map[y][x] = misc.map_char.wall
                end
            end
        end
    end
end

local function add_doors_to_map(rooms, map)
    for _, room in ipairs(rooms) do
        if room.doors then
            for _, door in ipairs(room.doors) do
                map[door.y][door.x] = misc.map_char.door
            end
        end
    end
end

function M.generate_with_bsp_trees(map, pathfinding_nodes, config)
    local leaf = bsp_leaves.generate_leaves(config.map, config.leaves)
    local rooms = bsp_rooms.generate_rooms_from_leaves(leaf, config.rooms)
    local corridors = bsp_corridors.generate_corridors(rooms, pathfinding_nodes, config.map)

    add_rooms_to_map(rooms, map)
    add_corridors_to_map(corridors, map)
    add_doors_to_map(rooms, map)

    return rooms
end

return M
