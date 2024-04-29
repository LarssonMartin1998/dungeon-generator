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

return M
