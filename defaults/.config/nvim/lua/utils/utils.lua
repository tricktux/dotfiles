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

local function nnoremap(lhs, rhs, opts)
    if lhs == nil then
        log.error('Empty lhs variable')
        return
    end
    -- Always set mode to n
    -- Always add noremap to opts
    -- Do not modify orignal options
    log.trace("opts = ", opts)
    if vim.tbl_isempty(opts) then
        copts = {}
    else
        copts = vim.deepcopy(opts)
    end
    copts.noremap = true
    -- Remove and check buffer option from opts
    if table_removekey(copts, 'buffer') == true then
        -- Call buffer version
        log.trace("calling buffer mapping for: ", lhs)
        vim.api.nvim_buf_set_keymap(0, 'n', lhs, rhs, copts)
        return
    end
    log.trace("calling global mapping for: ", lhs)
    vim.api.nvim_set_keymap('n', lhs, rhs, copts)
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

local function create_augroups(definitions)
    for group_name, definition in pairs(definitions) do
        vim.api.nvim_command('augroup ' .. group_name)
        vim.api.nvim_command('autocmd!')
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten {'autocmd', def}, ' ')
            vim.api.nvim_command(command)
        end
        vim.api.nvim_command('augroup END')
    end
end

-- Sample usage
-- local autocmds = {
-- startup = {
-- {"VimEnter",        "*",      [[lua sourceCScope()]]};
-- }
-- }

-- create_augroups(autocmds)

return {
    create_augroups = create_augroups,
    dump = dump,
    is_mod_available = is_mod_available,
    table_length = table_length,
    table_removekey = table_removekey,
    nnoremap = nnoremap
}
