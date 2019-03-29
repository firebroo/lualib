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

function _M.str_split(str, pat)
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

function _M.str_explode_one(str, pat)
    local index = str:find(pat)
    if index == nil then
        return str, nil
    end
    return str:sub(1, index-1), str:sub(index+1, -1)
end

function _M.str_trim(s) 
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

function _M.var_dump(var, level)
    local split_char     = '\r\n'
    local split_table    = '    '
    local sz_ret         = ''
    
    if level == nil then
        level = 0
    end
    
    local function tabs(n)
        local sz_tabs = ''
        for i = 0, n do
            sz_tabs = sz_tabs .. split_table
        end

        return sz_tabs
    end
    
    local function dump(var, ret)
        for k, v in pairs(var) do
            local sz_key = _M.var_dump(k)
            local sz_val = _M.var_dump(v)
            if (sz_key and sz_val) then
                ret = string.format("%s%s[%s] = %s,%s", ret, tabs(level), 
                     _M.var_dump(k), _M.var_dump(v, level+1), split_char)
            end
        end     
        return ret
    end

    local sz_type = type(var)
    if sz_type == "number" then
        sz_ret = sz_ret .. var
    elseif sz_type == "boolean" then
        sz_ret = sz_ret .. tostring(var)
    elseif sz_type == "string" then
        sz_ret = sz_ret .. string.format("%q", var)
    elseif sz_type == "table" then
        sz_ret = sz_ret .. "{" .. split_char
        sz_ret = dump(var, sz_ret)
        local metatable = getmetatable(var)
        if metatable ~= nil and type(metatable.__index) == "table" then
            sz_ret = dump(metatable.__index, sz_ret)
        end
        sz_ret = sz_ret .. tabs(level-1) .. "}"
    elseif sz_type == "function" then
        sz_ret = sz_ret .. tostring(var)
    elseif sz_type == "nil" then
        return nil
    end

   return sz_ret
end

return _M
