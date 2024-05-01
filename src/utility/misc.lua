local M = {}

M.directions = {
    { 0,  -1 }, -- Up
    { 1,  0 },  -- Right
    { 0,  1 },  -- Down
    { -1, 0 }   -- Left
}

M.map_char = {
    empty = " ",
    wall = "#",
    floor = ".",
    door = "+"
}

function M.debug_draw_blocked_nodes_delayed(nodes, width, height, delay)
    M.debug_draw_blocked_nodes(nodes, width, height)
    os.execute("sleep " .. delay)
    os.execute("clear")
end

function M.debug_draw_blocked_nodes(nodes, width, height)
    for y = 1, height do
        local line = ""
        for x = 1, width do
            if nodes[y][x].is_passable then
                line = line .. " "
            else
                line = line .. "X"
            end
        end
        print(line)
    end
end

return M
