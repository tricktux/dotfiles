local log = require('utils/log')

local function create(definitions)
    for group_name, definition in pairs(definitions) do
        log.trace("Setting augroup = ", group_name)
        vim.cmd('augroup ' .. group_name)
        vim.cmd('autocmd!')
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten {'autocmd', def}, ' ')
            log.trace(command)
            vim.cmd(command)
        end
        vim.cmd('augroup END')
    end
end

return {create = create}
