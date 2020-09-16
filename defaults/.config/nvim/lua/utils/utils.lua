local log = require('utils/log')
local luv = vim.loop

-- List of useful vim helper functions
-- >vim.tbl_*
--  >vim.tbl_count
-- >vim.validate
-- >vim.deepcopy

-- Similar to python's pprint. Usage: lua dump({1, 2, 3})
local function dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

local function has_unix() return package.config:sub(1, 1) == [[/]] end

local function has_win() return package.config:sub(1, 1) == [[\]] end

local function isdir(path)
  vim.validate {path = {path, 's'}}
  local stat = luv.fs_stat(path)
  if stat == nil then return nil end
  if stat.type == "directory" then return true end
  return nil
end

local function isfile(path)
    vim.validate {path = {path, 's'}}
    local stat = luv.fs_stat(path)
    if stat == nil then return nil end
    if stat.type == "file" then return true end
    return nil
end

local function file_fuzzer(path)
    vim.validate{path = {path, 's'}}
    
    local epath = vim.fn.expand(path)
    if isdir(epath) == nil then
        log.error("Path provided is not valid: ", path)
        return
    end

    log.trace('file_fuzzer: path = ', epath)
    if vim.fn.exists(':FZF') > 0 then
        vim.cmd('Files ' .. epath)
        return
    end
    
    -- Raw handling of file selection
    -- Save cwd
    local dir = vim.fn.getcwd()
    -- CD to new location
    vim.cmd("lcd " .. epath)
    -- Select file
    local file = vim.fn.input('e ' .. epath, '', 'file')
    -- Sanitize file
    if file == nil then
        return
    end
    if isfile(file) == nil then
        vim.cmd([[echoerr "Selected file does not exists" ]] .. file)
        vim.cmd("lcd " .. dir)
        return
    end
    vim.cmd("e " .. file)
    vim.cmd("lcd " .. dir)
end

local function table_removekey(table, key)
    vim.validate {table = {table, 't'}}
    vim.validate {key = {key, 's'}}

    local element = table[key]
    if element == nil then return nil end
    table[key] = nil
    return element
end

local function is_mod_available(name)
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
    table_removekey = table_removekey,
    has_unix = has_unix,
    has_win = has_win,
    isdir = isdir,
    isfile = isfile,
    file_fuzzer = file_fuzzer,
}
