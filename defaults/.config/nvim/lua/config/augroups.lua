local log = require('utils/log')
local api = vim.api

local function create(definitions)
  for group_name, definition in pairs(definitions) do
    log.info("Setting augroup = ", group_name)
    vim.cmd('augroup ' .. group_name)
    vim.cmd('autocmd!')
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten {'autocmd', def}, ' ')
      log.info(command)
      vim.cmd(command)
    end
    vim.cmd('augroup END')
  end
end

local function deprecated()
  create {
    highlight_yank = {
      {
        "TextYankPost", "*",
        [[silent! lua require'vim.highlight'.on_yank{timeout = 250}]]
      }
    }
  }
end

local function setup()
  if vim.fn.has('nvim-0.7') <= 0 then
    deprecated()
    return
  end

  local id = api.nvim_create_augroup('highlight_yank', {clear = true})
  api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank {timeout = 250} end,
    pattern = '*',
    group = id
  })
end

return {create = create, setup = setup}
