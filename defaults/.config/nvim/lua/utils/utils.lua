-- Similar to python's pprint. Usage: lua dump({1, 2, 3})
function dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

function is_mod_available(name)
    if package.loaded[name] then
        return true
    end
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
}
