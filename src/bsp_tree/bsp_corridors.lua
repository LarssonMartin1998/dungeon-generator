local M = {}

function decimal_to_base(input)
    local num = tonumber(input)
    if not num then
        return input
    end

    if num < 0 then
        error("Number must be non-negative")
    end

    local chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local base = #chars -- 62
    if num == 0 then
        return "0"
    end

    local result = ""
    while num > 0 do
        local index = (num % base) + 1
        result = chars:sub(index, index) .. result
        num = math.floor(num / base)
    end

    return result
end

local function get_room_dist_from_center_sqrd(map_center, room)
    local room_center = { room.x + room.width * 0.5, room.y + room.height * 0.5 }
    local x = room_center[1] - map_center[1]
    local y = room_center[2] - map_center[2]
    return math.abs(x * x + y * y)
end

local function sort_rooms_from_map_center(rooms, width, height)
    local map_center = { width * 0.5, height * 0.5 }

    table.sort(rooms, function(a, b)
        local a_dist = get_room_dist_from_center_sqrd(map_center, a)
        local b_dist = get_room_dist_from_center_sqrd(map_center, b)
        return a_dist < b_dist
    end)
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
            line = line .. decimal_to_base(map[y][x])
        end
        print(line)
    end
end

local function debug_add_rooms_to_map(rooms, map)
    for i, room in ipairs(rooms) do
        for y = room.y, room.y + room.height do
            for x = room.x, room.x + room.width do
                map[y][x] = i
            end
        end

        -- Testing sorting
        debug_draw_map(map, 150, 60)
        os.execute("sleep 0.15")
        os.execute("clear")
    end
end

function M.generate_corridors(rooms, width, height)
    sort_rooms_from_map_center(rooms, width, height)

    map = debug_init_map(width, height)
    debug_add_rooms_to_map(rooms, map)
end

return M
