function Sleep(s)
    local ntime = os.clock() + s
    repeat until os.clock() > ntime
end

function table.contains(t, item)
    for _, value in ipairs(t) do
        if value:equal(item) then
            return true
        end
    end
    return false
end

function table.addUnique(t, item)
    if table.contains(t, item) then
        print("contains")
        return
    end
    t[#t+1] = item
end

function table.clear(t)
    for k, _ in pairs(t) do
        t[k] = nil
    end
end

function table.copy(t)
    local copy = {}
    for i, val in ipairs(t) do
        copy[i] = val
    end
    return copy
end