local utl = require('utils/utils')
local api = vim.api

local M = {}

M.__config = {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    spelling = {
      enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    presets = {
      operators = true, -- adds help for operators like d, y, ...
      motions = true, -- adds help for motions
      text_objects = true, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
  -- add operators that will trigger motion and text object completion
  -- to enable all native operators, set the preset / operators plugin above
  -- operators = { t = "toggle", c = "cd" },
  key_labels = {
    -- override the label used to display some keys. It doesn't effect WK in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
  },
  motions = {
    count = true,
  },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "→", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },
  window = {
    border = "none", -- none, single, double, shadow
    position = "bottom", -- bottom, top
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua ", "<plug>", "<Plug>"},
  show_help = true, -- show a help message in the command line for using WhichKey
  triggers = "auto", -- automatically setup triggers
  -- triggers = {"<leader>"} -- or specifiy a list manually
  triggers_nowait = {}, -- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
  triggers_blacklist = {
    -- list of mode / prefixes that should never be hooked by WhichKey
    -- this is mostly relevant for keymaps that start with a native binding
    i = { "j", "k" },
    v = { "j", "k" },
  },
}

local leader = {}
local leader_p = [[<leader>]]
leader.t = {
  name = 'toggle',
  j = 'file_browser',
  f = 'focus_plugin',
  e = 'terminal',
  t = 'tagbar',
  s = 'spelling',
  o = 'alternative_commenter',
}
leader.c = {
  name = 'cd',
  r = 'root',
  d = 'current_file',
  u = 'one_folder_up',
  c = 'display_curr_work_dir',
}
local wings = {
  name = 'wings',
  ['1'] = 'OneWins1',
  ['2'] = 'OneWins2',
  a = 'wings-dev',
  s = 'SupportFiles',
}

local edit_random_file_type = {
  name = 'random_file_type',
  c = {'<cmd>UtilsEditTmpFileCpp<cr>', 'cpp'},
  p = {'<cmd>UtilsEditTmpFilePython<cr>', 'python'},
  m = {'<cmd>UtilsEditTmpFileMarkdown<cr>', 'markdown'},
  v = {'<cmd>UtilsEditTmpFileVim<cr>', 'vim'},
  l = {'<cmd>UtilsEditTmpFileLua<cr>', 'lua'},
  g = {'<cmd>UtilsEditTmpFileGen<cr>', 'general_enter_extension'},
}

local function ff(arg)
  vim.validate {arg = {arg, 's'}}
  return require('utils.utils').file_fuzzer(arg)
end

local function ff_dotfiles()
  local arg = utl.has_unix() and vim.g.dotfiles or [[$APPDATA\dotfiles]]
  return ff(arg)
end
local lua_plugins = vim.g.std_data_path .. [[/site/pack/packer]]

leader.e = {
  name = 'edit',
  d = {ff_dotfiles, 'dotfiles'},
  h = {function() ff('$HOME') end, 'home'},
  c = {function() ff(vim.fn.getcwd()) end, 'current_dir'},
  t = edit_random_file_type,
  p = {function() ff(lua_plugins) end, 'lua_plugins_path'},
  l = {function() ff(vim.g.vim_plugins_path) end, 'vim_plugins_path'},
  v = {function() ff('$VIMRUNTIME') end, 'vimruntime'},
  w = wings,
  a = 'add folder/file',
}
local sessions = {
  name = 'sessions',
  s = 'save',
  l = 'load',
  e = 'load_default',
}
leader.j = {
  name = 'misc',
  ['2'] = '2_char_indent',
  ['4'] = '4_char_indent',
  ['8'] = '8_char_indent',
  w = 'wings_syntax',
  ['.'] = 'repeat_last_command',
  s = 'sync_from_start',
  c = 'count_last_search',
  ['-'] = {'<cmd>UtilsFontZoomOut<cr>', 'font_decrease'},
  ['='] = {'<cmd>UtilsFontZoomIn<cr>', 'font_increase'},
  e = sessions,
}
leader.b = {
  name = 'buffers/bookmarks',
  d = 'delete_current',
  l = 'delete_all',
}
leader.n = {
  name = 'num_representation',
  h = 'ascii_to_hex',
  c = 'hex_to_ascii',
  r = 'radical_viewer',
  a = 'get_ascii_cursor',
}
leader.v = {
  name = 'version_control',
  s = 'status',
  a = 'add',
  c = 'commit',
  p = 'push',
  u = 'pull/update',
  l = 'log',
  S = {'<cmd>SignifyToggle<cr>' ,'signify_toggle'},
  d = {'<cmd>SignifyDiff<cr>' ,'signify_diff'},
}
local function ewr() return require('plugin.report'):edit_weekly_report() end
leader.w = {
  name = 'wiki',
  o = 'open',
  a = 'add',
  s = 'search',
  r = {ewr, 'weekly_report_open'},
}
leader.o = {
  name = 'comments',
  I = 'reduce_indent',
  i = 'increase_indent',
  a = 'append',
  u = 'update_header_date',
  e = 'end_of_if_comment',
  t = 'add_todo',
  d = 'delete',
}
leader.P = {
  name = 'plugins',
  i = {'<cmd>PlugInstall<cr>', 'install'},
  u = {'<cmd>PlugUpdate<cr>', 'update'},
  r = {'<cmd>UpdateRemotePlugins<cr>', 'update_remote_plugins'},
  g = {'<cmd>PlugUpgrade<cr>', 'upgrade_vim_plug'},
  s = {'<cmd>PlugSearch<cr>', 'search'},
  l = {'<cmd>PlugClean<cr>', 'clean'},
}
local telescope = '<cmd>lua require("telescope.builtin").'
local git = {
  name = 'git',
  f = {telescope .. 'git_files()<cr>', 'files'},
  C = {telescope .. 'git_commits()<cr>', 'commits'},
  c = {telescope .. 'git_bcommits()<cr>', 'commits_current_buffer'},
  b = {telescope .. 'git_branches()<cr>', 'branches'},
  s = {telescope .. 'git_status()<cr>', 'status'},
  S = {telescope .. 'git_stash()<cr>', 'stash'},
}
leader['?'] = {telescope .. 'live_grep()<cr>', 'live_grep'}
leader['/'] = {'<plug>search_grep', 'search_grip'}
leader.f = {
  name = 'fuzzers',
  g = git,
  b = {telescope .. 'buffers()<cr>', 'buffers'},
  f = {telescope .. 'find_files()<cr>', 'files'},
  o = {telescope .. 'vim_options()<cr>', 'vim_options'},
  O = {telescope .. 'colorscheme()<cr>', 'colorscheme'},
  L = {telescope .. 'current_buffer_fuzzy_find()<cr>', 'lines_current_buffer'},
  t = {telescope .. 'current_buffer_tags()<cr>', 'tags_curr_buffer'},
  T = {telescope .. 'tags()<cr>', 'tags_all_buffers'},
  s = {telescope .. 'tagstack()<cr>', 'tags_stack'},
  r = {telescope .. 'treesitter()<cr>', 'treesitter'},
  [';'] = {telescope .. 'command_history()<cr>', 'command_history'},
  ['/'] = {telescope .. 'search_history()<cr>', 'search_history'},
  F = {telescope .. 'oldfiles()<cr>', 'oldfiles'},
  h = {telescope .. 'help_tags()<cr>', 'helptags'},
  y = {telescope .. 'filetypes()<cr>', 'filetypes'},
  a = {telescope .. 'autocommands()<cr>', 'autocommands'},
  m = {telescope .. 'keymaps()<cr>', 'keymaps'},
  M = {telescope .. 'man_pages()<cr>', 'man_pages'},
  c = {telescope .. 'commands()<cr>', 'commands'},
  q = {telescope .. 'quickfix()<cr>', 'quickfix'},
  l = {telescope .. 'loclist()<cr>', 'locationlist'},
  d = {telescope .. 'reloader()<cr>', 'reload_lua_modules'},
}
leader.d = 'duplicate_char'
leader.p = 'paste_from_system'
leader.y = 'yank_to_system'
leader.C = {'<cmd>Calendar<cr>', 'calendar'}

local lleader = {}
local lleader_p = [[<localleader>]]
lleader['8'] = 'print_hex'
lleader['<'] = 'print_prev_command_output'
lleader['?'] = 'rot13_encode_motion'
lleader['q'] = 'format_motion'
lleader['~'] = 'swap_case_motion'
lleader.e = {'<plug>terminal_send_line', 'send_line_terminal'}
lleader.E = {'<plug>terminal_send_line', 'send_file_terminal'}
lleader.c = {
  name = 'var_case_change',
  s = {'<plug>to_snake_case', 'to_snake_case'},
  c = {'<plug>to_camel_case', 'to_camel_case'},
  b = {'<plug>to_camel_back_case', 'to_camel_back_case'},
  k = {'<plug>to_kebak_case', 'to_kebak_case'},
}
lleader.k = {'<plug>make_project', 'make_project'}
lleader.j = {'<plug>make_file', 'make_file'}
lleader.f = {'<plug>format_code', 'format_code'}
lleader.f = {'<plug>refactor_code', 'refactor_code'}

local rbracket = {}
local rbracket_p = '['
rbracket.c = 'next_diff'
rbracket.p = {'<cmd>diffput<cr>', 'diffput'}
rbracket.g = {'<cmd>diffget<cr>', 'diffget'}
rbracket.y = 'yank_from_next_lines'
rbracket.d = 'delete_next_lines'
rbracket.o = 'comment_next_lines'
rbracket.m = 'move_line_below'
rbracket.q = 'next_quickfix_item'
rbracket.l = 'next_location_list_item'
rbracket.t = 'goto_tag_under_cursor'
rbracket.T = 'goto_tag_under_cursor_on_right_win'
rbracket.f = 'goto_file_under_cursor'
rbracket.F = 'goto_file_under_cursor_on_right_win'
rbracket.i = 'goto_include_under_cursor'
rbracket.I = 'goto_include_under_cursor_on_right_win'
rbracket.e = 'goto_define_under_cursor'
rbracket.E = 'goto_define_under_cursor_on_right_win'
rbracket.z = 'scroll_right'
rbracket.Z = 'scroll_up'
rbracket.s = 'goto_next_spell_error'
rbracket.S = 'fix_next_spell_error'
rbracket[']'] = 'goto_next_function'
rbracket[')'] = 'goto_next_unmatched_parenthesis'
rbracket['}'] = 'goto_next_unmatched_brace'
rbracket['/'] = 'goto_next_comment'
rbracket['#'] = 'goto_next_unmatched_defined_if'

local lbracket = {}
local lbracket_p = ']'
lbracket.c = 'prev_diff'
lbracket.p = {'<cmd>diffput<cr>', 'diffput'}
lbracket.g = {'<cmd>diffget<cr>', 'diffget'}
lbracket.y = 'yank_from_prev_lines'
lbracket.d = 'delete_prev_lines'
lbracket.o = 'comment_prev_lines'
lbracket.m = 'move_line_up'
lbracket.q = 'prev_quickfix_item'
lbracket.l = 'prev_location_list_item'
lbracket.t = 'pop_tag_stack'
lbracket.T = 'goto_tag_under_cursor_on_left_win'
lbracket.f = 'go_back_one_file'
lbracket.F = 'goto_file_under_cursor_on_left_win'
lbracket.i = 'goto_include_under_cursor'
lbracket.I = 'goto_include_under_cursor_on_left_win'
lbracket.e = 'goto_define_under_cursor'
lbracket.E = 'goto_define_under_cursor_on_left_win'
lbracket.z = 'scroll_left'
lbracket.Z = 'scroll_down'
lbracket.s = 'goto_prev_spell_error'
lbracket.S = 'fix_prev_spell_error'
lbracket['['] = 'goto_prev_function'
lbracket['('] = 'goto_prev_unmatched_parenthesis'
lbracket['{'] = 'goto_prev_unmatched_brace'
lbracket['#'] = 'goto_prev_unmatched_defined_if'
lbracket['/'] = 'goto_prev_comment'
lbracket['"'] = 'which_key_ignore'
lbracket[']'] = 'which_key_ignore'
lbracket['%'] = 'which_key_ignore'

function M:setup()
  if not utl.is_mod_available('which-key') then
    api.nvim_err_writeln('which-key module not available')
    return
  end

  local wk = require("which-key")
  wk.setup(self.__config)
  wk.register(leader, {prefix = leader_p})
  wk.register(lleader, {prefix = lleader_p})
  wk.register(lbracket, {prefix = lbracket_p})
  wk.register(rbracket, {prefix = rbracket_p})
end

return M
