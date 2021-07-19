local utl = require('utils.utils')
local line = require('config.plugins.lualine')
local api = vim.api

local M = {}

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
