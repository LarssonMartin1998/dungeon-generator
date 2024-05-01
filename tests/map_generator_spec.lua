local map_generator = require("src.map_generator")
local a_star = require("src.pathfinding.a_star")

describe("Map generation", function()
    it("Makes sure that all of the rooms are connected", function()
        local configs = {
            {
                map = {
                    width = 45,
                    height = 45
                },
                leaves = {
                    depth = 4,
                    map_padding = 8,
                    min_size = 14
                },
                rooms = {
                    padding = 2,
                    min_size = 4
                }
            },
            {
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
            },
            {
                map = {
                    width = 320,
                    height = 70
                },
                leaves = {
                    depth = 5,
                    map_padding = 8,
                    min_size = 20
                },
                rooms = {
                    padding = 5,
                    min_size = 8
                }
            },
        }

        local num_iterations = 1000
        for i, config in ipairs(configs) do
            print("Config: " .. i)
            for j = 1, num_iterations do
                print("Iteration: " .. j)
                local map, pathfinding_nodes, rooms = map_generator.get_randomized_map(config)
                local start = rooms[1]
                for i = 2, #rooms do
                    local goal = rooms[i]
                    local path = a_star.calculate_path(
                        pathfinding_nodes,
                        config.map.width,
                        config.map.height,
                        start.x,
                        start.y,
                        goal.x,
                        goal.y)

                    assert.is_not_nil(path, "Path should not be nil")
                end
            end
        end
    end)
end)
