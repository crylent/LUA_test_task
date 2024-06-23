require("Model")
require("Point")

local model = Model:new()
model:dump()
local quit = false
while not quit do
    local cmd_is_correct = false
    while not cmd_is_correct do
        io.write("\016 ")
        local cmd = {}
        for token in string.gmatch(io.read(), "[^%s]+") do
            cmd[#cmd+1] = token
        end

        if #cmd >= 1 and cmd[1] == "q" then
            quit = true
            cmd_is_correct = true
        elseif #cmd >= 4 and cmd[1] == "m" then
            local x, y = tonumber(cmd[2]), tonumber(cmd[3])
            if x >= 0 and x < model.width and y >= 0 and y < model.height then
                local from = Point:new(x, y)
                local to = nil

                local dir = cmd[4]
                if dir == "l" then
                    to = Point:new(x - 1, y)
                elseif dir == "r" then
                    to = Point:new(x + 1, y)
                elseif dir == "u" then
                    to = Point:new(x, y - 1)
                elseif dir == "d" then
                    to = Point:new(x, y + 1)
                end

                if to ~= nil then
                    cmd_is_correct = true
                    model:move(from, to)
                end
            end
        end
        if not cmd_is_correct then
            io.write("\027[A\027[2K")
        end
    end
end