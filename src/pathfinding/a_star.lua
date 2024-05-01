local mathutils = require("src.utility.math")
local misc = require("src.utility.misc")

-- This entire A* implementation can be heavily optimized, however, I don't think that it's
-- necessary for this project. But if you were to do it, it could be done by using a priority queue.
local M = {}

local function create_node(x, y, width, height)
    local is_passable = x > 1 and x < width and y > 1 and y < height
    return {
        x = x,
        y = y,
        is_passable = is_passable,
    }
end

local function is_inside_map(width, height, x, y)
    return x >= 1 and x <= width and y >= 1 and y <= height
end

local function check_neighbour(nodes, width, height, x, y)
    if not is_inside_map(width, height, x, y) then
        return false
    end

    if not nodes[y][x].is_passable then
        return false
    end

    return true
end

local function get_passable_neighbours(node, nodes, width, height)
    local neighbors = {}
    for _, dir in ipairs(misc.directions) do
        local neighbour_x = node.x + dir[1]
        local neighbour_y = node.y + dir[2]

        if check_neighbour(nodes, width, height, neighbour_x, neighbour_y) then
            table.insert(neighbors, nodes[neighbour_y][neighbour_x])
        end
    end

    return neighbors
end

local function node_in_set(open_set, element)
    for _, value in ipairs(open_set) do
        if value == element then
            return true
        end
    end
    return false
end

local function create_path_context()
    return {}
end

local function get_or_create_path_data(context, node)
    if not context[node] then
        context[node] = {
            x = node.x,
            y = node.y,
            total_estimated_cost = math.huge, -- (f)
            cost_from_start = math.huge,      -- (g)
            estimated_cost_to_goal = 0,       -- (h)
            parent = nil
        }
    end
    return context[node]
end

local function construct_path(goal_node, context)
    local path = {}
    local current = get_or_create_path_data(context, goal_node)
    while current do
        table.insert(path, 1, {
            x = current.x,
            y = current.y
        })
        current = current.parent
    end

    return path
end

function M.create_nodes(width, height)
    local nodes = {}
    for y = 1, height do
        nodes[y] = {}
        for x = 1, width do
            nodes[y][x] = create_node(x, y, width, height)
        end
    end
    return nodes
end

function M.calculate_path(nodes, width, height, start_x, start_y, goal_x, goal_y)
    local context = create_path_context()
    local start_node = nodes[start_y][start_x]
    local goal_node = nodes[goal_y][goal_x]

    if not start_node.is_passable or not goal_node.is_passable then
        return nil
    end

    local start_data = get_or_create_path_data(context, start_node)
    start_data.cost_from_start = 0
    start_data.estimated_cost_to_goal = mathutils.get_distance_sqrd(start_x, start_y, goal_x, goal_y)
    start_data.total_estimated_cost = start_data.estimated_cost_to_goal

    local open_set = {}
    table.insert(open_set, start_data) -- Insert path data instead of node

    while #open_set > 0 do
        table.sort(open_set, function(data1, data2)
            return data1.total_estimated_cost < data2.total_estimated_cost
        end)

        local current_data = table.remove(open_set, 1)
        local current_node = nodes[current_data.y][current_data.x]

        if current_node == goal_node then
            return construct_path(current_node, context)
        end

        local neighbors = get_passable_neighbours(current_node, nodes, width, height)
        for _, neighbor in ipairs(neighbors) do
            local neighbor_data = get_or_create_path_data(context, neighbor)
            local tentative_cost = current_data.cost_from_start + 1

            if tentative_cost < neighbor_data.cost_from_start then
                neighbor_data.parent = current_data
                neighbor_data.cost_from_start = tentative_cost
                neighbor_data.estimated_cost_to_goal = mathutils.get_distance_sqrd(
                    neighbor.x,
                    neighbor.y,
                    goal_node.x,
                    goal_node.y
                )
                neighbor_data.total_estimated_cost =
                    neighbor_data.cost_from_start + neighbor_data.estimated_cost_to_goal

                if not node_in_set(open_set, neighbor_data) then
                    table.insert(open_set, neighbor_data)
                end
            end
        end
    end

    return nil
end

return M
