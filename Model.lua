require("Point")
require("util")
require("Gems")

Model = {
    width = 10,
    height = 10,

    field = {},
    affected_cells = {},
    all_affected_cells = {},
    moves = {},
    possible_moves_counter = 0
}

function Model:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self:init()
    return obj
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
            row[x] = Gem.rand(forbidden)
        end
        self.field[y] = row
    end

    self:initMoves()
end

function Model:move(from, to)
    self.affected_cells = { from, to }
    self.all_affected_cells = { from, to }
    self.field[from.y][from.x], self.field[to.y][to.x] = self.field[to.y][to.x], self.field[from.y][from.x]
    self:tick();
    self:recalcMoves();
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
            self.field[cell.y][cell.x] = Gems.temp
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
        local point = Point:new(x, y)
        table.addUnique(self.affected_cells, point)
        table.addUnique(self.all_affected_cells, point)
    end
    local point = Point:new(x, 0)
    table.addUnique(self.affected_cells, point)
    table.addUnique(self.all_affected_cells, point)
    self.field[0][x] = Gem.rand({})
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
    os.execute("cls")
    local str = "  "
    for x = 0, self.width-1, 1 do
        str = str..x.." "
    end
    str = str.."\n"
    for y = 0, self.height-1, 1 do
        str = str..y.." "
        for x = 0, self.width-1, 1 do
            str = str..(self.field[y][x].char).." "
        end
        str = str.."\n"
    end
    print(str)
end

function Model:dumpMoves()
    local str = "  "
    for x = 0, self.width-1, 1 do
        str = str..x.." "
    end
    str = str.."\n"
    for y = 0, self.height-1, 1 do
        str = str..y.." "
        for x = 0, self.width-1, 1 do
            str = str..(self.moves[y][x]).." "
        end
        str = str.."\n"
    end
    print(str)
end

function Model:initMoves()
    for y = 0, self.height-1, 1 do
        self.moves[y] = {}
        for x = 0, self.width-1, 1 do
            self:countPossibleMoves(x, y)
        end
    end
    if self.possible_moves_counter == 0 then
        self:mix()
    end
end

function Model:recalcMoves()
    local left_x, right_x, max_y = self.width, 0, 0
    for _, cell in ipairs(self.all_affected_cells) do
        local x, y = cell.x, cell.y
        if x < left_x then
            left_x = x
        end
        if x > right_x then
            right_x = x
        end
        if y > max_y then
            max_y = y
        end
    end

    if left_x - 2 < 0 then
        left_x = 0
    else
        left_x = left_x - 2
    end

    if right_x + 2 >= self.width then
        right_x = self.width - 1
    else
        right_x = right_x + 2
    end

    if max_y + 2 >= self.height then
        max_y = self.height - 1
    else
        max_y = max_y + 2
    end

    for y = 0, max_y, 1 do
        for x = left_x, right_x, 1 do
            self:countPossibleMoves(x, y)
        end
    end

    while self.possible_moves_counter == 0 do
        self:mix()
    end
end

function Model:countPossibleMoves(x, y)
    local m = 0

    if x-1 >= 0 and self:testForPossibleMatch(x, y, x-1, y) then
        m = m + 1
    end
    if x+1 < self.width and self:testForPossibleMatch(x, y, x+1, y) then
        m = m + 1
    end
    if y-1 >= 0 and self:testForPossibleMatch(x, y, x, y-1) then
        m = m + 1
    end
    if y+1 < self.height and self:testForPossibleMatch(x, y, x, y+1) then
        m = m + 1
    end

    local last_value = self.moves[y][x]
    if last_value ~= nil then
        self.possible_moves_counter = self.possible_moves_counter - last_value
    end
    self.moves[y][x] = m
    self.possible_moves_counter = self.possible_moves_counter + m
end

function Model:testForPossibleMatch(x0, y0, x, y)
    local gem = self.field[y0][x0]

    local row = self.field[y]

    local match_x = false
    for i = -2, 0, 1 do
        if i + x >= 0 then
            local match = true
            for j = 0, 2, 1 do
                local xx = x + i + j
                if xx >= self.width or (y0 == y and xx == x0) or (i+j~=0 and row[xx] ~= gem) then
                    match = false
                    break
                end
            end
            if match then
                match_x = true
                break
            end
        end
    end

    if match_x then
        return true
    end

    local match_y = false
    for i = -2, 0, 1 do
        if i + y >= 0 then
            local match = true
            for j = 0, 2, 1 do
                local yy = y + i + j
                if yy >= self.height or (x0 == x and yy == y0) or (i+j ~= 0 and self.field[yy][x] ~= gem) then
                    match = false
                    break
                end
            end
            if match then
                match_y = true
                break
            end
        end
    end

    return match_y
end

function Model:mix()
    while self.possible_moves_counter == 0 do
        local x1, y1, x2, y2 = self:randX(), self:randY(), self:randX(), self:randY()
        local gem1, gem2 = self.field[y1][x1], self.field[y2][x2]
        if gem1 ~= gem2
            and not self:testForPossibleMatch(x1, y1, x2, y2)
            and not self:testForPossibleMatch(x2, y2, x1, y1)
        then
            self:move(Point:new(x1, y1), Point:new(x2, y2))
        end
    end
end

function Model:randX()
    return math.random(self.width) - 1
end

function Model:randY()
    return math.random(self.height) - 1
end