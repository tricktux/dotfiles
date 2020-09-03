local log = require('utils/log')

-- Similar to python's pprint. Usage: lua dump({1, 2, 3})
function dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

local function table_removekey(table, key)
    if table == nil or key == nil then
        log.error('Invalid table or key value provided: ', table, key)
        return nil
    end
    local element = table[key]
    if element == nil then return nil end
    table[key] = nil
    return element
end

local function table_length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function is_mod_available(name)
    if package.loaded[name] then return true end
    for _, searcher in ipairs(package.searchers or package.loaders) do
        local loader = searcher(name)
        if type(loader) == 'function' then
            package.preload[name] = loader
            return true
        end
    end
    return false
end

return {
    dump = dump,
    is_mod_available = is_mod_available,
    table_length = table_length,
    table_removekey = table_removekey
}
