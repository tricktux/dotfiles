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

local function set_text_settings()
  vim.opt.conceallevel = 0
  vim.opt.textwidth = 0
  vim.opt.wrap = true
  vim.opt.foldenable = true
  vim.opt.complete:append('kspell')
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.softtabstop = 2
  vim.opt.comments:append({b = '-'})
  vim.opt.spelllang = {'en_us', 'es'}
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

  id = api.nvim_create_augroup('Cursor', {clear = true})
  api.nvim_create_autocmd('CursorHold', {
    command = [[silent! update checktime]],
    pattern = '*',
    desc = 'Avoid manual save, and autoread',
    group = id
  })

  id = api.nvim_create_augroup('Terminal', {clear = true})
  api.nvim_create_autocmd('TermOpen', {
    callback = function()
      log.info('terminal autocmd called')
      vim.opt.number = false
      vim.opt.relativenumber = false
      vim.opt.bufhidden = 'hide'
      vim.keymap.set('n', [[q]], [[ZZ]], {silent = true, buffer = true})
      vim.keymap.set('n', [[<M-`>]], [[ZZ]], {silent = true, buffer = true})
      local color = vim.opt.background:get() == 'dark' and 'Black' or 'White'
      vim.cmd('highlight Terminal guibg=' .. color)
      vim.opt.winhighlight = 'NormalFloat:Terminal'
    end,
    pattern = '*',
    desc = 'Better settings for terminal',
    group = id
  })

  id = api.nvim_create_augroup('FiletypesLua', {clear = true})
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
      vim.opt.suffixesadd = {".scp", ".cmd", ".bat"}
      log.info('wings_syntax autocmd called')
    end,
    pattern = 'wings_syntax',
    desc = 'Better go to files for wings filetypes',
    group = id
  })
  api.nvim_create_autocmd('Filetype', {
    callback = function()
      vim.opt.relativenumber = true
      log.info('nerdtree autocmd called')
    end,
    pattern = 'nerdtree',
    desc = 'nerdtree relativenumber',
    group = id
  })
  api.nvim_create_autocmd('Filetype', {
    callback = function()
      log.info('help autocmd called')
      vim.opt.relativenumber = true
      vim.keymap.set('n', [[q]], [[:helpc<cr>]],
                     {silent = true, buffer = true, desc = 'exit help'})
      vim.keymap.set('n', [[g0]], [[g0]],
                     {silent = true, buffer = true, desc = 'show sections'})
    end,
    pattern = 'help',
    desc = 'Better mappings for help filetypes',
    group = id
  })
  api.nvim_create_autocmd('Filetype', {
    callback = function()
      log.info('markdown autocmd called')
      set_text_settings()
    end,
    pattern = {'markdown', 'mkd'},
    desc = 'Better settings for markdown',
    group = id
  })
  api.nvim_create_autocmd('Filetype', {
    callback = function()
      log.info('tex autocmd called')
      set_text_settings()
      vim.opt.formatoptions:remove('tc')
    end,
    pattern = 'tex',
    desc = 'Better settings for tex',
    group = id
  })
  api.nvim_create_autocmd('Filetype', {
    callback = function()
      log.info('mail autocmd called')
      vim.opt.wrap = true
      vim.opt.textwidth = 72
    end,
    pattern = 'mail',
    desc = 'Better settings for mail',
    group = id
  })
  api.nvim_create_autocmd('Filetype', {
    callback = function()
      log.info('c autocmd called')
      local tab = vim.fn.has('unix') > 0 and 2 or 4
      vim.opt.wrap = false
      vim.opt.tabstop = tab
      vim.opt.shiftwidth = tab
      vim.opt.softtabstop = tab
    end,
    pattern = {'c', 'cpp'},
    desc = 'Better settings for c',
    group = id
  })
end

return {create = create, setup = setup}
