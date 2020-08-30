-- Similar to python's pprint. Usage: lua dump({1, 2, 3})
function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
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
  create_augroups = create_augroups
}
