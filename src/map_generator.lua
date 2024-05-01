local bsp_handler = require("src.bsp_tree.bsp_handler")
local a_star = require("src.pathfinding.a_star")

local M = {}

local function init_map(width, height)
    local map = {}

    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            map[y][x] = " "
        end
    end

    return map
end

local function reverse_pathfinding_passage_state(pathfinding_nodes, width, height)
    for y = 1, height do
        for x = 1, width do
            pathfinding_nodes[y][x].is_passable = not pathfinding_nodes[y][x].is_passable
        end
    end
end

local function draw_map(map, width, height)
    for y = 1, height do
        local line = ""
        for x = 1, width do
            line = line .. map[y][x]
        end
        print(line)
    end
end

function M.get_randomized_map(config)
    local map = init_map(config.map.width, config.map.height)
    local pathfinding_nodes = a_star.create_nodes(config.map.width, config.map.height)
    local rooms = bsp_handler.generate_with_bsp_trees(map, pathfinding_nodes, config)
    reverse_pathfinding_passage_state(pathfinding_nodes, config.map.width, config.map.height)

    return map, pathfinding_nodes, rooms
end

function M.run()
    local config = {
        map = {
            width = 130,
            height = 48
        },
        leaves = {
            depth = 3,
            map_padding = 8,
            min_size = 14
        },
        rooms = {
            padding = 4,
            min_size = 6
        }
    }

    local map = M.get_randomized_map(config)
    draw_map(map, config.map.width, config.map.height)
end

return M
