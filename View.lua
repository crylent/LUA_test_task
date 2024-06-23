View = {}

function View:new(model)
    local obj = {}
    obj.model = model
    setmetatable(obj, self)
    self.score = 0
    self.__index = self
    return obj
end

function View:dump()
    os.execute("cls")
    local str = "  "
    for x = 0, self.model.width-1, 1 do
        str = str..x.." "
    end
    str = str.."\n"
    for y = 0, self.model.height-1, 1 do
        str = str..y.." "
        for x = 0, self.model.width-1, 1 do
            str = str..(self.model.field[y][x].char).." "
        end
        str = str.."\n"
    end
    str = str.."\nScore: "..self.score
    print(str)
end