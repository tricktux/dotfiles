local log = require('utils/log')
local api = vim.api

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

local function setup()
  create {
    highlight_yank = {
      {
        "TextYankPost", "*",
        [[silent! lua require'vim.highlight'.on_yank{timeout = 250}]]
      }
    }
  }
end

return {create = create, setup = setup}
