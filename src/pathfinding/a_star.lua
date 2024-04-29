local mathutils = require("src.utility.math")
local misc = require("src.utility.misc")

local M = {}

local function create_node(x, y, width, height)
    local is_passable = x > 1 and x < width and y > 1 and y < height
    return {
        total_estimated_cost = math.huge, -- (f)
        cost_from_start = math.huge,      -- (g)
        estimated_cost_to_goal = 0,       -- (h)
        x = x,
        y = y,
        is_passable = is_passable,
        parent = nil
    }
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

local function is_inside_map(width, height, x, y)
    return x >= 1 and x <= width and y >= 1 and y <= height
end

local function check_neighbour(nodes, width, height, x, y)
    if not is_inside_map(width, height, x, y) then
        return false
    end

    local is_passable = nodes[y][x].is_passable
    if not is_passable then
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

local function construct_path(goal_node)
    local path = {}
    local current = goal_node
    while current do
        table.insert(path, 1, {
            x = current.x,
            y = current.y
        })
        current = current.parent
    end

    return path
end

local function node_in_set(open_set, element)
    for _, value in ipairs(open_set) do
        if value == element then
            return true
        end
    end
    return false
end

function M.calculate_path(nodes, width, height, start_x, start_y, goal_x, goal_y)
    local start_node = nodes[start_y][start_x]
    local goal_node = nodes[goal_y][goal_x]

    if not start_node.is_passable or not goal_node.is_passable then
        return nil
    end

    start_node.cost_from_start = 0
    start_node.estimated_cost_to_goal = mathutils.get_euclidian_distance(start_x, start_y, goal_x, goal_y)
    start_node.total_estimated_cost = start_node.estimated_cost_to_goal

    local open_set = {}
    table.insert(open_set, start_node)

    while #open_set > 0 do
        table.sort(open_set, function(node1, node2)
            return node1.total_estimated_cost < node2.total_estimated_cost
        end)
        local current = table.remove(open_set, 1)

        if current == goal_node then
            return construct_path(current)
        end

        local neighbors = get_passable_neighbours(current, nodes, width, height)
        for _, neighbor in ipairs(neighbors) do
            local tentative_cost = current.cost_from_start + 1

            if neighbor.is_passable and tentative_cost < neighbor.cost_from_start then
                neighbor.parent = current
                neighbor.cost_from_start = tentative_cost
                neighbor.estimated_cost_to_goal = mathutils.get_euclidian_distance(
                    neighbor.x,
                    neighbor.y,
                    goal_node.x,
                    goal_node.y
                )
                neighbor.total_estimated_cost = neighbor.cost_from_start + neighbor.estimated_cost_to_goal

                if not node_in_set(open_set, neighbor) then
                    table.insert(open_set, neighbor)
                end
            end
        end
    end

    return nil
end

return M
