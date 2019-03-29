local _M = { _VERSION = '0.01' }

local mt = { __index = _M }

function _M.clone(object)
    local lookup_table = {}
  
    local function _copy(object)
        if type(object) ~= "table" then 
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end

        local new_table = {}
        lookup_table[object] = new_table
	    
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
  
    return setmetatable(_copy(object), mt)
end

function _M.split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
    
        last_end = e + 1
        s, e, cap = str:find(fpat, last_end)
    end
    
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    
    return setmetatable(t, mt)
end

function _M.table_has_value(t, ele)
    for _, v in pairs(t) do
        if ele == v then
            return true
        end
    end

    return false
end

return _M
