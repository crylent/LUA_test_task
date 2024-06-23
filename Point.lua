Point = {}

function Point:new(x, y)
    local obj = {}
    obj.x = x
    obj.y = y
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Point:copy()
    local newObj = {}
    newObj.x = self.x
    newObj.y = self.y
    newObj.copy = self.copy
    setmetatable(newObj, self)
    return newObj
end

function Point:equal(other)
    return self.x == other.x and self.y == other.y
end