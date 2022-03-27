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
    desc = 'Highlight text on Yank',
    group = id
  })

  id = api.nvim_create_augroup('Filetypes', {clear = true})
  api.nvim_create_autocmd('Filetype', {
    callback = function()
      vim.keymap.set('n', [[<s-j>]], [[:b#<cr>]],
                     {silent = true, buffer = true, desc = 'Remap next buffer'})
      vim.keymap.set('n', [[<C-j>]], [[)]],
                     {silent = true, buffer = true, desc = 'Next section'})
      vim.keymap.set('n', [[<C-k>]], [[(]],
                     {silent = true, buffer = true, desc = 'Prev section'})
    end,
    pattern = 'fugitive',
    desc = 'Better mappings for fugitive filetypes',
    group = id
  })

  -- TODO: Not really working
  api.nvim_create_autocmd('Filetype', {
    callback = function()
      vim.opt.suffixesadd:append(".scp,.cmd,.bat")
      print("hello world")
    end,
    pattern = 'wings_syntax',
    desc = 'Better go to files for wings filetypes',
    group = id
  })
end

return {create = create, setup = setup}
