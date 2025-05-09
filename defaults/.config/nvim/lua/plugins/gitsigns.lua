local utl = require('utils.utils')
local map = require('mappings')
-- local line = require("plugins.lualine")
local log = require('utils.log')

local M = {}

if vim.fn.has('nvim-0.10') <= 0 then
  return M
end

local function format_status(status)
  local added, changed, removed = status.added, status.changed, status.removed
  local status_txt = {}
  if added and added > 0 then
    table.insert(status_txt, '+' .. added)
  end
  if changed and changed > 0 then
    table.insert(status_txt, '~' .. changed)
  end
  if removed and removed > 0 then
    table.insert(status_txt, '-' .. removed)
  end
  return table.concat(status_txt, ' ')
end

local function next_hunk()
  if vim.opt.diff:get() then
    vim.cmd('normal! ]czz')
    return
  end

  require('gitsigns').next_hunk()
end

local function prev_hunk()
  if vim.opt.diff:get() then
    vim.cmd('normal! [czz')
    return
  end

  require('gitsigns').prev_hunk()
end

local function on_attach(bufnr)
  local opts = { silent = true, buffer = bufnr }
  local prefix = map.vcs.prefix .. 'g'
  local gs = require('gitsigns')
  local mappings = {
    l = { gs.select_hunk, 'select_hunk' },
    s = { gs.stage_hunk, 'stage_hunk' },
    S = { gs.stage_buffer, 'stage_buffer' },
    u = { gs.undo_stage_hunk, 'undo_stage_hunk' },
    d = { gs.diffthis, 'diffthis' },
    t = { gs.toggle_signs, 'toggle_signs' },
    r = { gs.reset_hunk, 'reset_hunk' },
    R = { gs.reset_buffer, 'reset_buffer' },
    b = { gs.blame_line, 'blame_line' },
    p = { gs.preview_hunk, 'preview_hunk' },
    j = { gs.next_hunk, 'next_hunk' },
    k = { gs.prev_hunk, 'prev_hunk' },
  }
  map.keymaps_set(mappings, 'n', opts, prefix)
  mappings = {
    [']c'] = { next_hunk, 'next_hunk' },
    ['[c'] = { prev_hunk, 'prev_hunk' },
  }
  map.keymaps_set(mappings, 'n', opts)
end

local function status_line()
  if vim.fn.exists('b:gitsigns_status') <= 0 then
    return ''
  end

  return vim.b.gitsigns_head .. ' ' .. vim.b.gitsigns_status
end

function M.setup()
  require('gitsigns').setup({
    -- Kinda annoying
    numhl = false,
    keymaps = nil,
    watch_gitdir = { interval = 888, follow_files = true },
    sign_priority = 6,
    status_formatter = format_status,
    on_attach = on_attach,
  })

  log.info('ins_left(): gitsigns')
  -- line:ins_left({ status_line, color = { gui = "bold" } })
end

return {
  'lewis6991/gitsigns.nvim',
  event = 'VeryLazy',
  config = function()
    M.setup()
  end,
}
