local utl = require('utils.utils')
local line = require('config.plugins.lualine')
local map = require('utils.keymap')
local api = vim.api

local M = {}

function M.setup_zen_mode()
  require("zen-mode").setup {
    window = {
      backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
      -- height and width can be:
      -- * an absolute number of cells when > 1
      -- * a percentage of the width / height of the editor when <= 1
      -- * a function that returns the width or the height
      width = .70, -- width of the Zen window
      height = 1, -- height of the Zen window
      -- by default, no options are changed for the Zen window
      -- uncomment any of the options below, or add other vim.wo options you want to apply
      options = {
        signcolumn = "no", -- disable signcolumn
        number = false, -- disable number column
        relativenumber = false, -- disable relative numbers
        -- cursorline = false, -- disable cursorline
        -- cursorcolumn = false, -- disable cursor column
        -- foldcolumn = "0", -- disable fold column
        -- list = false, -- disable whitespace characters
      },
    },
    plugins = {
      -- disable some global vim options (vim.o...)
      -- comment the lines to not apply the options
      options = {
        enabled = true,
        ruler = false, -- disables the ruler text in the cmd line area
        showcmd = false, -- disables the command in the last line of the screen
      },
      twilight = { enabled = false }, -- enable to start Twilight when zen mode opens
      gitsigns = { enabled = false }, -- disables git signs
      tmux = { enabled = false }, -- disables the tmux statusline
      -- this will change the font size on kitty when in zen mode
      -- to make this work, you need to set the following kitty options:
      -- - allow_remote_control socket-only
      -- - listen_on unix:/tmp/kitty
      kitty = {
        enabled = false,
        font = "+4", -- font size increment
      },
    },
    -- callback where you can add custom code when the Zen window opens
    --[[ on_open = function(win)
    end, ]]
    -- callback where you can add custom code when the Zen window closes
    --[[ on_close = function()
    end, ]]
  }
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('which-key module not available')
    return
  end

  require('which-key').register{
    ["<plug>focus_toggle"] = {'<cmd>ZenMode<cr>', "zen_mode_focus_toggle"},
  }
end

function M.setup_focus()
  -- Initially mappings are enabled
  local focus = require('focus')

  -- Displays line numbers in the focussed window only
  -- Not displayed in unfocussed windows
  -- Default: true
  focus.number = false
  focus.relativenumber = false
  -- Enable auto highlighting for focussed/unfocussed windows
  -- Default: false
  focus.winhighlight = false
  -- vim.cmd('hi link UnfocusedWindow CursorLine')
  -- vim.cmd('hi link FocusedWindow VisualNOS')
  -- focus.enable = false
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('which-key module not available')
    return
  end

  require('which-key').register{
    ["<leader>tw"] = {'<cmd>FocusToggle<cr>', "focus_mode_toggle_mappings"},
    ["<a-h>"] = {function() focus.split_command('h') end, "window_switch_left"},
    ["<a-j>"] = {function() focus.split_command('j') end, "window_switch_down"},
    ["<a-k>"] = {function() focus.split_command('k') end, "window_switch_up"},
    ["<a-l>"] = {function() focus.split_command('l') end, "window_switch_right"},
  }
end

function M.setup_kommentary()
  local config = require('kommentary.config')
  config.configure_language("wings_syntax", {
    single_line_comment_string = "//",
    prefer_single_line_comments = true,
  })
  config.configure_language("dosini", {
    single_line_comment_string = ";",
    prefer_single_line_comments = true,
  })

  vim.g.kommentary_create_default_mappings = false  -- Somthing

  --[[ The default mapping for line-wise operation; will toggle the range from
  commented to not-commented and vice-versa, will use a single-line comment. ]]
  vim.api.nvim_set_keymap("n", "-", "<Plug>kommentary_line_default", {})
  --[[ The default mapping for visual selections; will toggle the range from
  commented to not-commented and vice-versa, will use multi-line comments when
  the range is longer than 1 line, otherwise it will use a single-line comment. ]]
  vim.api.nvim_set_keymap("x", "-", "<Plug>kommentary_visual_default<C-c>", {})
  --[[ The default mapping for motions; will toggle the range from commented to
  not-commented and vice-versa, will use multi-line comments when the range
  is longer than 1 line, otherwise it will use a single-line comment. ]]
  vim.api.nvim_set_keymap("n", "0", "<Plug>kommentary_motion_default", {})

  --[[--
  Creates mappings for in/decreasing comment level.
  ]]
  --[[ vim.api.nvim_set_keymap("n", "<leader>oic", "<Plug>kommentary_line_increase", {})
  vim.api.nvim_set_keymap("n", "<leader>oi", "<Plug>kommentary_motion_increase", {})
  vim.api.nvim_set_keymap("x", "<leader>oi", "<Plug>kommentary_visual_increase", {})
  vim.api.nvim_set_keymap("n", "<leader>odc", "<Plug>kommentary_line_decrease", {})
  vim.api.nvim_set_keymap("n", "<leader>od", "<Plug>kommentary_motion_decrease", {})
  vim.api.nvim_set_keymap("x", "<leader>od", "<Plug>kommentary_visual_decrease", {}) ]]
end

function M.setup_comment_frame()
  require('nvim-comment-frame').setup({

    -- if true, <leader>cf keymap will be disabled
    disable_default_keymap = true,

    -- adds custom keymap
    -- keymap = '<leader>cc',
    -- multiline_keymap = '<leader>C',

    -- start the comment with this string
    start_str = '//',

    -- end the comment line with this string
    end_str = '//',

    -- fill the comment frame border with this character
    fill_char = '-',

    -- width of the comment frame
    frame_width = 70,

    -- wrap the line after 'n' characters
    line_wrap_len = 50,

    -- automatically indent the comment frame based on the line
    auto_indent = true,

    -- add comment above the current line
    add_comment_above = true,

    -- configurations for individual language goes here
    languages = {
    }
  })

  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('which-key module not available')
    return
  end

  local wk = require("which-key")
  local leader = {}
  local leader_p = [[<leader>]]
  leader.o = {
    name = 'comments',
    m = {require('nvim-comment-frame').add_multiline_comment, "add_multiline_comment"},
  }
  wk.register(leader, {prefix = leader_p})
end

function M.setup_starlite()
  map.nnoremap('*', '<cmd>lua require"starlite".star()<cr>')
  map.nnoremap('g*', '<cmd>lua require"starlite".g_star()<cr>')
  map.nnoremap('#', '<cmd>lua require"starlite".hash()<cr>')
  map.nnoremap('g#', '<cmd>lua require"starlite".g_hash()<cr>')
end

function M.setup_bookmarks()
  vim.g.bookmark_no_default_key_mappings = 1
  vim.g.bookmark_manage_per_buffer = 0
  vim.g.bookmark_save_per_working_dir = 0
  vim.g.bookmark_dir = vim.g.std_data_path .. '/bookmarks'
  vim.g.bookmark_auto_save = 0
  vim.g.bookmark_auto_save_file = vim.g.bookmark_dir .. '/bookmarks'
  vim.g.bookmark_highlight_lines = 1

  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('which-key module not available')
    return
  end

  local wk = require("which-key")
  local leader = {}
  local leader_p = [[<leader>]]
  leader.B = {
    name = 'bookmarks',
    t = {"<Plug>BookmarkToggle", "BookmarkToggle"},
    i = {"<Plug>BookmarkAnnotate", "BookmarkAnnotate"},
    a = {"<Plug>BookmarkShowAll", "BookmarkShowAll"},
    n = {"<Plug>BookmarkNext", "BookmarkNext"},
    p = {"<Plug>BookmarkPrev", "BookmarkPrev"},
    c = {"<Plug>BookmarkClear", "BookmarkClear"},
    x = {"<Plug>BookmarkClearAll", "BookmarkClearAll"},
    k = {"<Plug>BookmarkMoveUp", "BookmarkMoveUp"},
    j = {"<Plug>BookmarkMoveDown", "BookmarkMoveDown"},
    o = {"<Plug>BookmarkLoad", "BookmarkLoad"},
    s = {"<Plug>BookmarkSave", "BookmarkSave"},
  }
  wk.register(leader, {prefix = leader_p})
end

function M.setup_bdelete()
  local bd = require('close_buffers')
  bd.setup({
    filetype_ignore = {},  -- Filetype to ignore when running deletions
    file_glob_ignore = {},  -- File name glob pattern to ignore when running deletions (e.g. '*.md')
    file_regex_ignore = {}, -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
    preserve_window_layout = { 'this', 'nameless' },  -- Types of deletion that should preserve the window layout
    next_buffer_cmd = nil,  -- Custom function to retrieve the next buffer when preserving window layout
  })

  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('which-key module not available')
    return
  end

  local wk = require("which-key")
  local leader = {}
  local leader_p = [[<leader>]]
  leader.b = {
    name = 'buffers',
    d = {function() bd.delete({type = 'this'}) end, 'buffer_delete_current'},
    l = {function() bd.delete({type = 'all', force = true}) end, 'buffer_delete_all'},
    n = {function() bd.delete({type = 'nameless'}) end, 'buffer_delete_nameless'},
    g = {function() bd.delete({glob = vim.fn.input("Please enter glob (ex. *.lua): ")}) end, 'buffer_delete_glob'},
  }
  wk.register(leader, {prefix = leader_p})
end

function M.setup_sneak()
  vim.g["sneak#absolute_dir"] = 1
  vim.g["sneak#label"] = 1

  -- " repeat motion
  -- Using : for next f,t is cumbersome, use ' for that, and ` for marks 
  map.map("'", '<Plug>Sneak_;')
  map.map(',', '<Plug>Sneak_,')

  -- " 1-character enhanced 'f'
  map.nmap('f', '<Plug>Sneak_f')
  map.nmap('F', '<Plug>Sneak_F')
  -- " 1-character enhanced 't'
  map.nmap('t', '<Plug>Sneak_t')
  -- " label-mode
  map.nmap('s', '<Plug>SneakLabel_s')
  map.nmap('S', '<Plug>SneakLabel_S')

  -- TODO: See a way not to have to map these
  -- Wait for: https://github.com/justinmk/vim-sneak/pull/248
  -- vim.g["sneak#disable_mappings"] = 1
  -- " visual-mode
  map.nmap('T', '%')
  map.xmap('s', 's')
  map.xmap('S', 'S')
  -- " operator-pending-mode
  map.omap('s', 's')
  map.omap('S', 'S')
  -- " visual-mode
  map.xmap('f', 'f')
  map.xmap('F', 'F')
  -- " operator-pending-mode
  map.omap('f', 'f')
  map.omap('F', 'F')
  -- " visual-mode
  map.xmap('t', 't')
  map.xmap('T', '%')
  -- " operator-pending-mode
  map.omap('t', 't')
  map.omap('T', '%')
end

local function obsession_status()
  return vim.fn['ObsessionStatus']('S:' ..
  vim.fn
  .fnamemodify(vim.v.this_session,
  ':t:r'), '$')
end

function M.setup_papercolor()
  vim.g.flux_day_colorscheme = 'PaperColor'
  vim.g.flux_night_colorscheme = 'PaperColor'
  vim.g.flux_day_statusline_colorscheme = 'PaperColor_light'
  vim.g.flux_night_statusline_colorscheme = 'PaperColor_dark'
  if vim.fn.has('unix') > 0 and vim.fn.executable('luajit') > 0 then
    vim.g.flux_enabled = 0
    vim.fn['flux#Manual']()
  else
    vim.cmd [[
    augroup FluxLike
    autocmd!
    autocmd VimEnter,BufEnter * call flux#Flux()
    augroup END
    ]]

    vim.g.flux_enabled = 1
    vim.g.flux_api_lat = 27.972572
    vim.g.flux_api_lon = -82.796745

    vim.g.flux_night_time = 2000
    vim.g.flux_day_time = 700
  end
  vim.g.PaperColor_Theme_Options = {
    ['language'] = {
      ['python'] = {['highlight_builtins'] = 1},
      ['c'] = {['highlight_builtins'] = 1},
      ['cpp'] = {['highlight_standard_library'] = 1}
    },
    ['theme'] = {
      ['default'] = {
        ['transparent_background'] = 0,
        ['allow_bold'] = 1,
        ['allow_italic'] = 1
      }
    }
  }
end

function M.setup_neoterm()

  vim.g.neoterm_automap_keys = ''
  vim.g.neoterm_term_per_tab = 1
  vim.g.neoterm_use_relative_path = 1
  vim.g.neoterm_default_mod = ''
  vim.g.neoterm_autoinsert = 0
  -- " Potential substitue
  -- " https://github.com/Shougo/deol.nvim/blob/master/doc/deol.txt
  -- " there is also vimshell
  if not utl.is_mod_available('vimp') then
    api.nvim_err_writeln("vimp was set, but module not found")
    return
  end
  local vimp = require('vimp')
  vimp.nnoremap({'override'}, '<plug>terminal_toggle', function()
    require('utils.utils').exec_float_term('Ttoggle')
  end)
  vimp.nnoremap({'override'}, '<plug>terminal_new', '<cmd>Tnew<cr>')
  vimp.nnoremap({'override'}, '<plug>terminal_send_file',
  '<cmd>TREPLSendFile<cr>')
  -- " Use gx{text-object} in normal mode
  -- vimp.nnoremap({'override'}, '<plug>terminal_send', '<Plug>(neoterm-repl-send)')
  if vim.fn.exists('$TMUX') > 0 then
    vimp.nnoremap({'override'}, '<plug>terminal_send_line', function()
      local cline = vim.fn.shellescape(vim.fn.getline('.'))
      if cline == '' or cline == nil then return end
      -- \! = ! which means target (-t) last active tmux pane (!)
      vim.cmd([[silent !tmux send-keys -t \! ]] .. cline .. [[ Enter]])
    end)
    vimp.xnoremap({'override'}, '<plug>terminal_send', function()
      local csel = vim.fn.shellescape(
      require('utils.utils').get_visual_selection())
      if csel == '' or csel == nil then return end
      -- \! = ! which means target (-t) last active tmux pane (!)
      vim.cmd([[silent !tmux send-keys -t \! ]] .. csel .. [[ Enter]])
    end)
  else
    vimp.nnoremap({'override'}, '<plug>terminal_send_line',
    '<Plug>(neoterm-repl-send-line)')
  end
end

function M.setup_pomodoro()
  vim.g.pomodoro_use_devicons = 0
  if vim.fn.executable('dunst') > 0 then
    vim.g.pomodoro_notification_cmd =
    "notify-send 'Pomodoro' 'Session ended' && " ..
    "mpv ~/.config/dotfiles/notification_sounds/cool_notification1.mp3 " ..
    "2>/dev/null&"
  elseif vim.fn.executable('powershell') > 0 then
    local notif = os.getenv("APPDATA") .. '/dotfiles/scripts/win/win_vim_notification.ps1'
    if vim.fn.filereadable(notif) then
      vim.g.pomodoro_notification_cmd = notif
    end
  end
  vim.g.pomodoro_log_file = vim.g.std_data_path .. '/pomodoro_log'

  line:ins_left{
    vim.fn['pomo#status_bar'],
    color = {fg = line.colors.orange, gui = 'bold'},
    left_padding = 0
  }
end

function M.setup_luadev()
  if not utl.is_mod_available('lspconfig') then
    api.nvim_err_writeln('misc.lua: lspconfig module not available')
    return
  end

  local luadev = require("lua-dev").setup({
    library = {
      vimruntime = true, -- runtime path
      -- full signature, docs and completion of vim.api, vim.treesitter,
      -- vim.lsp and others
      types = true,
      -- List of plugins you want autocompletion for
      plugins = {'plenary'}
    },
    -- pass any additional options that will be merged in the final lsp config
    lspconfig = {
      cmd = {"lua-language-server"},
      on_attach = require('config.lsp').on_lsp_attach
    }
  })

  local lspconfig = require('lspconfig')
  lspconfig.sumneko_lua.setup(luadev)
end

function M.setup_neogit()
  if not utl.is_mod_available('neogit') then
    api.nvim_err_writeln('misc.lua: neogit module not available')
    return
  end

  require('neogit').setup {}
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('which-key module not available')
    return
  end
  -- open commit popup
  -- neogit.open({ "commit" })
  require("which-key").register {
    ["<leader>vo"] = {require('neogit').open, "neogit_open"}
  }
end

function M.setup_git_messenger()
  vim.g.git_messenger_always_into_popup = true

  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('which-key module not available')
    return
  end

  require("which-key").register {
    ["<leader>vm"] = {'<cmd>GitMessenger<cr>', "git_messenger"}
  }
end

function M.setup_iswap()
  if not utl.is_mod_available('iswap') then
    api.nvim_err_writeln('misc.lua: iswap module not available')
    return
  end

  require('iswap').setup {
    -- The keys that will be used as a selection, in order
    -- ('asdfghjklqwertyuiopzxcvbnm' by default)
    keys = 'qwertyuiop',
    -- Grey out the rest of the text when making a selection
    -- (enabled by default)
    grey = 'enabled',
    -- Highlight group for the sniping value (asdf etc.)
    -- default 'Search'
    hl_snipe = 'ErrorMsg',
    -- Highlight group for the visual selection of terms
    -- default 'Visual'
    hl_selection = 'WarningMsg',
    -- Highlight group for the greyed background
    -- default 'Comment'
    hl_grey = 'LineNr'
  }
  if not utl.is_mod_available('which-key') then
    api.nvim_err_writeln('misc.lua: which-key module not available')
    return
  end
  require("which-key").register {
    ["<localleader>s"] = {require('iswap').iswap, "iswap_arguments"}
  }
end

function M.setup_obsession()
  vim.g.obsession_no_bufenter = 1
  line:ins_right{
    obsession_status,
    color = {fg = line.colors.blue, gui = 'bold'},
    right_padding = 0
  }
end

return M
