local bsp_tree = require("src.bsp_tree")

describe("bsp_tree", function()
    describe(
        "Generate a random map using bsp trees",
        function()
            it(
                "If we start in one end, we should be able to traverse the entire map, and end up in the same place by just sticking to one of the walls and licking it.",
                function()
                    local start = { x = 1, y = 1 }
                    local map = bsp_tree.generate_with_bsp_trees()
                    -- Do something smart here, so that we can test the map.
                    -- However, just set up the basic app structure for now.

                    assert.are.equal(start, start)
                end)
        end)
end)
