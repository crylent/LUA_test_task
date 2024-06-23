require("Point")
require("util")

Model = {
    width = 10,
    height = 10,
    gems = { "A", "B", "C", "D", "E", "F" },

    field = {},
    affected_cells = {}
}

function Model:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self:init()
    return obj
end

function Model:rand(forbidden)
    local allowed = {}
    for _, val in ipairs(self.gems) do
        local allowed_val = true
        for _, fval in ipairs(forbidden) do
            if val == fval then
                allowed_val = false
            end
        end
        if allowed_val then
            allowed[#allowed+1] = val
        end
    end

    return allowed[math.random(1, #allowed)]
end

function Model:init()
    self.field = {}
    for y = 0, self.height-1, 1 do
        local row = {}
        for x = 0, self.width-1, 1 do
            local forbidden = {}
            if x >= 2 and row[x-1] == row[x-2] then
                forbidden[1] = row[x-1]
            end
            if y >= 2 and self.field[y-1][x] == self.field[y-2][x] then
                forbidden[#forbidden+1] = self.field[y-1][x]
            end
            row[x] = self:rand(forbidden)
        end
        self.field[y] = row
    end
end

function Model:move(from, to)
    self.affected_cells = { from, to }
    self.field[from.y][from.x], self.field[to.y][to.x] = self.field[to.y][to.x], self.field[from.y][from.x]
    self:tick();
end

function Model:checkMatch(pos, dx, dy)
    local gem = self.field[pos.y][pos.x];
    local row = {}
    row[1] = pos
    local bottom_y = pos.y

    local pos1 = pos:copy()

    local continue = true
    while continue do
        pos1.x = pos1.x + dx
        pos1.y = pos1.y + dy
        if pos1.x >= self.width or pos1.y >= self.height or self.field[pos1.y][pos1.x] ~= gem then
            continue = false
        else
            row[#row+1] = pos1:copy()
            if pos1.y > bottom_y then
                bottom_y = pos1.y
            end
        end
    end
    print(bottom_y)

    local pos2 = pos:copy()
    continue = true
    while continue do
        pos2.x = pos2.x - dx
        pos2.y = pos2.y - dy
        if pos2.x < 0 or pos2.y < 0 or self.field[pos2.y][pos2.x] ~= gem then
            continue = false
        else
            row[#row+1] = pos2:copy()
        end
    end

    if #row >= 3 then
        for _, cell in ipairs(row) do
            self.field[cell.y][cell.x] = "*"
        end
        self:dump()
        Sleep(0.5)

        if dy == 1 then
            local bottom_cell = Point:new(pos.x, bottom_y)
            for _ = 1, #row, 1 do
                self:drop(bottom_cell)
            end
        else
            for _, cell in ipairs(row) do
                self:drop(cell)
            end
        end
    end
end

function Model:drop(origin)
    local x = origin.x
    for y = origin.y, 1, -1 do
        self.field[y][x] = self.field[y-1][x]
        table.addUnique(self.affected_cells, Point:new(x, y))
    end
    table.addUnique(self.affected_cells, Point:new(x, 0))
    self.field[0][x] = self:rand({})
    self:dump()
    Sleep(0.2)
end

function Model:tick()
    local affected = table.copy(self.affected_cells)
    table.clear(self.affected_cells)
    for _, cell in ipairs(affected) do
        self:checkMatch(cell, 1, 0);
        self:checkMatch(cell, 0, 1);
    end
    self:dump()
    
    if #self.affected_cells > 0 then
        self:tick()
    end
end

function Model:dump()
    --_ = io.read("l")
    os.execute("cls")
    --print(#self.affected_cells)
    local str = "  "
    for x = 0, self.width-1, 1 do
        str = str..x.." "
    end
    str = str.."\n"
    for y = 0, self.height-1, 1 do
        str = str..y.." "
        for x = 0, self.width-1, 1 do
            str = str..self.field[y][x].." "
        end
        str = str.."\n"
    end
    print(str)
end