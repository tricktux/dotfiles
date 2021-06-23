local utl = require('utils/utils')

local M = {}

function M.setup()
  if not utl.is_mod_available('gitsigns') then
    api.nvim_err_writeln('gitsigns module not available')
    return
  end

  require('gitsigns').setup {
    signs = {
      add = {hl = 'DiffAdd', text = '+'},
      change = {hl = 'DiffChange', text = '!'},
      delete = {hl = 'DiffDelete', text = '_'},
      topdelete = {hl = 'DiffDelete', text = '‾'},
      changedelete = {hl = 'DiffChange', text = '~'}
    },
    -- Kinda annoying
    numhl = false,
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,

      ['n ]c'] = {
        expr = true,
        "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"
      },
      ['n [c'] = {
        expr = true,
        "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"
      }

      -- ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      -- ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
      -- ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      -- ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      -- ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line()<CR>'
    },
    watch_index = {interval = 1000},
    sign_priority = 6,
    status_formatter = nil -- Use default
  }
  vim.cmd 'command! GitSignsStageHunk lua require"gitsigns".stage_hunk()'
  vim.cmd 'command! GitSignsUndoStageHunk lua require"gitsigns".undo_stage_hunk()'
  vim.cmd 'command! GitSignsResetHunk lua require"gitsigns".reset_hunk()'
  vim.cmd 'command! GitSignsPreviewHunk lua require"gitsigns".preview_hunk()'
  vim.cmd 'command! GitSignsBlameLine lua require"gitsigns".blame_line()'
  vim.cmd 'command! GitSignsResetBuffer lua require"gitsigns".reset_buffer()'
end

return M
