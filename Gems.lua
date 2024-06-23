Gem = {}

function Gem:new(char)
    local obj = {}
    obj.char = char
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Gem.rand(forbidden)
    local allowed = {}
    for _, val in ipairs(Gems) do
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

Gems = {
    Gem:new("A"),
    Gem:new("B"),
    Gem:new("C"),
    Gem:new("D"),
    Gem:new("E"),
    Gem:new("F"),

    temp = Gem:new("*")
}
