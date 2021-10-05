local utl = require('utils.utils')
local line = require('config.plugins.lualine')

local M = {}

local function format_status(status)
  local added, changed, removed = status.added, status.changed, status.removed
  local status_txt = {}
  if added and added > 0 then table.insert(status_txt, '+' .. added) end
  if changed and changed > 0 then table.insert(status_txt, '~' .. changed) end
  if removed and removed > 0 then table.insert(status_txt, '-' .. removed) end
  return table.concat(status_txt, ' ')
end

local function next_hunk()
  if vim.opt.diff:get() then
    vim.cmd "normal! ]czz"
    return
  end

  require("gitsigns").next_hunk()
end

local function prev_hunk()
  if vim.opt.diff:get() then
    vim.cmd "normal! [czz"
    return
  end

  require("gitsigns").prev_hunk()
end

local function on_attach(bufnr)
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('gitsigns.lua: which-key module not available')
    return false
  end

  local wk = require("which-key")
  local opts = {prefix = '<leader>vg', buffer = bufnr}
  local gs = require("gitsigns")
  local mappings = {
    name = 'gitsigns',
    l = {gs.select_hunk, 'select_hunk'},
    s = {gs.stage_hunk, 'stage_hunk'},
    S = {gs.stage_buffer, 'stage_buffer'},
    u = {gs.undo_stage_hunk, 'undo_stage_hunk'},
    d = {gs.diffthis, 'diffthis'},
    t = {gs.toggle_signs, 'toggle_signs'},
    r = {gs.reset_hunk, 'reset_hunk'},
    R = {gs.reset_buffer, 'reset_buffer'},
    b = {gs.blame_line, 'blame_line'},
    p = {gs.preview_hunk, 'preview_hunk'},
    j = {gs.next_hunk, 'next_hunk'},
    k = {gs.prev_hunk, 'prev_hunk'}
  }
  wk.register(mappings, opts)
  wk.register({
    ["]c"] = {next_hunk, 'next_hunk'},
    ["[c"] = {prev_hunk, 'prev_hunk'}
  }, {buffer = bufnr})

  if utl.is_mod_available('telescope') then
    local ts = require("telescope.builtin")
    opts.prefix = '<leader>vt'
    mappings = {
      name = 'telescope',
      f = {ts.git_files, 'files'},
      C = {ts.git_commits, 'commits'},
      c = {ts.git_bcommits, 'commits_current_buffer'},
      b = {ts.git_branches, 'branches'},
      s = {ts.git_status, 'status'},
      S = {ts.git_stash, 'stash'}
    }
    wk.register(mappings, opts)
  end
  return true
end

local function status_line()
  if vim.fn.exists('b:gitsigns_status') <= 0 then return '' end

  return vim.b.gitsigns_head .. ' ' .. vim.b.gitsigns_status
end

function M.setup()
  if not utl.is_mod_available('gitsigns') then
    vim.api.nvim_err_writeln('gitsigns module not available')
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
    keymaps = nil,
    watch_gitdir = {interval = 100, follow_files = true},
    sign_priority = 6,
    status_formatter = format_status,
    on_attach = on_attach
  }

  line:ins_left{status_line, color = {fg = line.colors.violet, gui = 'bold'}}
end

return M
