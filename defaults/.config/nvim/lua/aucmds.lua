local log = require('utils.log')
local api = vim.api

local M = {}

local function set_text_settings()
  vim.opt_local.wrap = true
  vim.opt_local.spell = true
  vim.opt.conceallevel = 0
  vim.opt.textwidth = 0
  vim.opt.foldenable = true
  vim.opt.complete:append('kspell')
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.comments:append({ b = '-' })
end

local function rename_buffer()
  local o = {
    prompt = 'Please new term name: ',
    default = 'term-',
  }
  local i = function(input)
    vim.cmd('silent keepalt noautocmd file ' .. input)
  end
  vim.ui.input(o, i)
end

M.setup = function()
  local id = api.nvim_create_augroup('highlight_yank', { clear = true })
  api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      vim.highlight.on_yank({ timeout = 250 })
    end,
    desc = 'Highlight text on Yank',
    group = id,
  })

  id = api.nvim_create_augroup('Cursor', { clear = true })
  api.nvim_create_autocmd('CursorHold', {
    command = [[silent! update | checktime]],
    pattern = '*',
    desc = 'Avoid manual save, autoread',
    group = id,
  })

  -- resize splits if window got resized
  id = api.nvim_create_augroup('resize_splits', { clear = true })
  vim.api.nvim_create_autocmd({ 'VimResized' }, {
    group = id,
    callback = function()
      vim.cmd('tabdo wincmd =')
    end,
  })

  id = api.nvim_create_augroup('Terminal', { clear = true })
  api.nvim_create_autocmd('TermOpen', {
    callback = function()
      log.info('terminal autocmd called')
      vim.opt_local.wrap = false
      vim.opt_local.spell = false
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.bufhidden = 'hide'
      vim.keymap.set('n', [[q]], [[ZZ]], { silent = true, buffer = true })
      vim.keymap.set('n', [[<M-`>]], [[ZZ]], { silent = true, buffer = true })
      vim.keymap.set('n', [[<c-r>]], rename_buffer, { silent = true, buffer = true })
    end,
    pattern = '*',
    desc = 'Better settings for terminal',
    group = id,
  })

  id = api.nvim_create_augroup('FiletypesLua', { clear = true })
  api.nvim_create_autocmd('FileType', {
    callback = function()
      log.info('orgagenda autocmd called')
      vim.opt_local.cursorline = true
    end,
    pattern = { 'qf', 'csv' },
    desc = 'Set cursor line where it makes sense',
    group = id,
  })
  api.nvim_create_autocmd('FileType', {
    callback = function()
      log.info('markdown autocmd called')
      set_text_settings()
      vim.cmd([[
        vnoremap <buffer> <localleader>Q :s/^/> /<CR>:noh<CR>``
        nnoremap <buffer> <localleader>Q :.,$s/^/> /<CR>:noh<CR>``
      ]])
    end,
    pattern = { 'markdown', 'mkd', 'text' },
    desc = 'Better settings for markdown',
    group = id,
  })
  api.nvim_create_autocmd('FileType', {
    callback = function()
      log.info('tex autocmd called')
      set_text_settings()
      vim.opt.formatoptions:remove('tc')
    end,
    pattern = 'tex',
    desc = 'Better settings for tex',
    group = id,
  })
  -- close some filetypes with <q>
  vim.api.nvim_create_autocmd('FileType', {
    group = id,
    pattern = {
      'qf',
      'help',
      'man',
      'notify',
      'lspinfo',
      'spectre_panel',
      'startuptime',
      'tsplayground',
      'PlenaryTestPopup',
    },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
    end,
  })
  api.nvim_create_autocmd('FileType', {
    callback = function()
      log.info('mail autocmd called')
      vim.opt.textwidth = 72
    end,
    pattern = 'mail',
    desc = 'Better settings for mail',
    group = id,
  })
  api.nvim_create_autocmd('FileType', {
    callback = function()
      log.info('c autocmd called')
      local tab = vim.fn.has('unix') > 0 and 2 or 4
      vim.opt.tabstop = tab
      vim.opt.shiftwidth = tab
    end,
    pattern = { 'c', 'cpp' },
    desc = 'Better settings for c',
    group = id,
  })

  id = api.nvim_create_augroup('cmdwin', { clear = true })
  vim.api.nvim_create_autocmd('CmdwinEnter', {
    group = id,
    desc = 'Disable some conflicting mappings',
    pattern = '*',
    callback = function()
      vim.keymap.set('n', [[<c-c>]], [[<c-c>]], { silent = true, buffer = true })
      vim.keymap.set('n', [[<cr>]], [[<cr>]], { silent = true, buffer = true })
    end,
  })

  id = api.nvim_create_augroup('Buf', { clear = true })
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = id,
    desc = 'Restore cursor on file open',
    pattern = '*',
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local lcount = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
      vim.api.nvim_feedkeys('zz', 'n', true)
    end,
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = id,
    desc = 'Set winbar',
    callback = function()
      local bufname = vim.api.nvim_buf_get_name(0)  -- Get the name of the current buffer
      local bufname_no_path = vim.fn.fnamemodify(bufname, ':t')  -- Strips the path, keeping just the file name
      vim.wo.winbar = bufname_no_path  -- Set the winbar
    end,  -- Call the function we defined
  })

  if vim.fn.has('nvim-0.9') <= 0 then
    id = api.nvim_create_augroup('Omni', { clear = true })
    vim.api.nvim_create_autocmd('TextChangedI', {
      group = id,
      desc = 'Temp fix for omnifunc',
      pattern = '*',
      callback = function()
        vim.opt.omnifunc = ''
      end,
    })
  end
end

return M
