-- File:           plugin.lua
-- Description:    Used to configure different plugins
-- Author:		    Reinaldo Molina
-- Email:          me at molinamail dot com
-- Created:        Tue Sep 08 2020 22:20
-- Last Modified:  Tue Sep 08 2020 22:20
local utl = require('utils/utils')
local log = require('utils/log')
local map = require('utils/keymap')
local aug = require('config/augroups')
local compl = require('config.plugins.completion')
local line = require('config.plugins.statusline')
local api = vim.api

local function setup_lspstatus()
  if not utl.is_mod_available('lsp-status') then
    api.nvim_err_writeln("lsp-status was set, but module not found")
    return
  end

  -- Default config is acceptable for unix
  if utl.has_unix() then
    require('lsp-status').config {}
    return
  end

  local config = {
    ['indicator_errors'] = 'e:',
    ['indicator_warnings'] = 'w:',
    ['indicator_info'] = 'i:',
    ['indicator_hint'] = 'h:',
    ['indicator_ok'] = 'ok',
    ['spinner_frames'] = {
      '(*---------)', '(--*-------)', '(-----*----)', '(--------*-)',
      '(---------*)', '(--------*-)', '(-----*----)', '(--*-------)',
      '(*---------)'
    },
    ['status_symbol'] = ''
  }
  require('lsp-status').config(config)
end

local function setup_treesitter()
  -- Mon Apr 05 2021 17:36:
  -- performance of treesitter in large files is very low.
  -- Keep as little modules enabled as possible.
  -- Also no status line
  -- No extra modules. Looking at you rainbow
  if not utl.is_mod_available('nvim-treesitter') then
    api.nvim_err_writeln('nvim-treesitter module not available')
    return
  end

  -- local ts = require'nvim-treesitter'
  local tsconf = require 'nvim-treesitter.configs'

  local config = {
    -- This line will install all of them
    -- one of "all", "language", or a list of languages
    ensure_installed = {
      "c", "cpp", "python", "lua", "java", "bash", "c_sharp", "rust", "json",
      "toml"
    },
    highlight = {
      enable = true -- false will disable the whole extension
      -- incremental_selection = {enable = true},
    },
    indent = {enable = false}
    -- textobjects = {enable = true}
  }

  -- if utl.is_mod_available('rainbow') then config["rainbow"] = {enable = true} end

  tsconf.setup(config)

  -- vim.cmd(
  -- "autocmd FileType c,cpp,python,lua,java,bash,rust,json,toml,cs setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()")
  -- if exists('g:lightline')
  -- let g:lightline.active.right[2] += [ 'sessions' ]
  -- let g:lightline.component_function['sessions'] =
  -- \ string(function('s:obsession_status'))
  -- endif
  -- Set highlights for PaperColor
  -- local hl = {
  -- 'highlight TSPunctDelimiter guifg=#00ad7f',
  -- 'highlight TSPunctSpecial guifg=#004e3d',
  -- 'highlight TSTagDelimiter guifg=#004257',
  -- 'highlight TSConstBuiltin guifg=#00d7af',
  -- 'highlight TSConstructor gui=Bold guifg=#8700d7',
  -- 'highlight TSVariableBuiltin guifg=#005faf',
  -- 'highlight TSStringRegex guifg=#afd700',
  -- 'highlight TSLiteral guifg=#00bcd4',
  -- 'highlight TSMethod gui=italic guifg=#d75f87',
  -- 'highlight TSField guifg=#afd7d7',
  -- 'highlight TSProperty guifg=#ffaf87',
  -- 'highlight TSParameterReference guifg=#005685',
  -- 'highlight TSAttribute guifg=#185d95',
  -- 'highlight TSTag guifg=#305b7e',
  -- 'highlight TSKeywordFunction guifg=#40596d',
  -- 'highlight TSKeywordOperator guifg=#1ac9ff',
  -- 'highlight TSTypeBuiltin guifg=#5f00ff',
  -- 'highlight TSNamespace guifg=#b71f1f',
  -- }

  -- for _, high in ipairs(hl) do
  -- vim.cmd(high)
  -- end
end

local function setup_formatter_clang()
  local clang_exe = nil
  if utl.has_win() then
    if utl.isfile([[C:\Program Files (x86)\LLVM\bin\clang-check.exe]]) then
      clang_exe = [[C:\Program Files (x86)\LLVM\bin\clang-check.exe]]
    end
  else
    if vim.fn.executable('clang-format') > 0 then clang_exe = 'clang-format' end
  end

  if clang_exe == nil then return nil end
  local args = {'--style=file', '-fallback-style="LLVM"'}
  return {exe = clang_exe, args = args, stdin = true}
end

local function setup_formatter()
  if not utl.is_mod_available('format') then
    api.nvim_err_writeln('format module not available')
    return
  end

  map.nnoremap([[<plug>format_code]], [[<cmd>Format<cr>]], {silent = true})
  local formatters = {}
  local clang = setup_formatter_clang()
  log.trace("clang_format = ", clang)
  if clang ~= nil then
    formatters['c'] = {clang_format = setup_formatter_clang}
    formatters['cpp'] = {clang_format = setup_formatter_clang}
  end
  if vim.fn.executable('lua-format') > 0 then
    formatters['lua'] = {
      lua_format = function()
        return {exe = "lua-format", args = {"--indent-width", 2}, stdin = true}
      end
    }
  end
  if vim.fn.executable('astyle') > 0 then
    formatters['java'] = {
      astyle = function()
        return {
          exe = "astyle",
          args = {"--indent", "spaces=2", "--style", "java"},
          stdin = true
        }
      end
    }
  end
  if vim.fn.executable('shfmt') > 0 then
    -- -mn = minify the code to reduce its size (implies -s)
    formatters['sh'] = {
      shfmt = function()
        return {exe = "shfmt", args = {"-mn"}, stdin = true}
      end
    }
  end
  if vim.fn.executable('cmake-format') > 0 then
    formatters['cmake'] = {
      cmake_format = function()
        return {exe = "cmake-format", args = {}, stdin = true}
      end
    }
  end
  local isort = nil
  if vim.fn.executable('isort') > 0 then
    isort = function()
      return {exe = "isort", args = {"-", "--quiet"}, stdin = true}
    end
  end
  local docformatter = nil
  if vim.fn.executable('docformatter') > 0 then
    docformatter = function()
      return {exe = "docformatter", args = {"-"}, stdin = true}
    end
  end
  local yapf = nil
  if vim.fn.executable('yapf') > 0 then
    yapf = function() return {exe = "yapf", args = {}, stdin = true} end
  end
  formatters['python'] = {
    isort = isort,
    yapf = yapf,
    docformatter = docformatter
  }

  log.trace("formatters = ", formatters)
  require('format').setup(formatters)
end

local function setup_scrollbar()
  if not utl.is_mod_available('scrollbar') then
    api.nvim_err_writeln('scrollbar module not available')
    return
  end

  local au = {
    scrollbar = {
      {
        "CursorMoved,VimResized,QuitPre,WinEnter,FocusGained", "*",
        "silent! lua require('scrollbar').show()"
      }, {"WinLeave,FocusLost", "*", "silent! lua require('scrollbar').clear()"}
    }
  }
  aug.create(au)
end

local function setup_lightbulb()
  if not utl.is_mod_available('nvim-lightbulb') then
    api.nvim_err_writeln('nvim-lightbulb module not available')
    return
  end

  vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]

  require'nvim-lightbulb'.update_lightbulb {
    sign = {
      enabled = true,
      -- Priority of the gutter sign
      priority = 10
    },
    float = {
      enabled = false,
      -- Text to show in the popup float
      text = "💡",
      -- Available keys for window options:
      -- - height     of floating window
      -- - width      of floating window
      -- - wrap_at    character to wrap at for computing height
      -- - max_width  maximal width of floating window
      -- - max_height maximal height of floating window
      -- - pad_left   number of columns to pad contents at left
      -- - pad_right  number of columns to pad contents at right
      -- - pad_top    number of lines to pad contents at top
      -- - pad_bottom number of lines to pad contents at bottom
      -- - offset_x   x-axis offset of the floating window
      -- - offset_y   y-axis offset of the floating window
      -- - anchor     corner of float to place at the cursor (NW, NE, SW, SE)
      -- - winblend   transparency of the window (0-100)
      win_opts = {}
    },
    virtual_text = {
      enabled = false,
      -- Text to show at virtual text
      text = "💡"
    }
  }
end

local function setup_telescope()
  if not utl.is_mod_available('telescope') then
    api.nvim_err_writeln('telescope module not available')
    return
  end

  local cmd_pref = [[<cmd>lua require'telescope.builtin'.]]
  -- Can't beat ctrlp honestly
  -- map.nmap("<plug>buffer_browser", cmd_pref .. [[buffers{show_all_buffers = true}<cr>]])
  map.nmap("<plug>mru_browser", cmd_pref .. [[oldfiles()<cr>]])

  local actions = require('telescope.actions')

  local config = {
    defaults = {
      -- Picker Configuration
      -- border = {},
      -- borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
      -- preview_cutoff = (utl.has_unix() and 120 or 9999),
      -- selection_strategy = "reset",

      -- Can choose EITHER one of these: horizontal, vertical, center
      -- layout_strategy = "horizontal",
      -- horizontal_config = {
      -- get_preview_width = function(columns, _)
      -- return math.floor(columns * 0.5)
      -- end,
      -- },

      -- get_window_options = function(...) end,
      -- To move to bottom, use strategy descending
      prompt_position = "top",
      sorting_strategy = "ascending",
      layout_strategy = "flex",
      winblend = 5,
      layout_defaults = {
        horizontal = {
          width_padding = 0.1,
          height_padding = 0.1,
          preview_width = 0.6
        },
        vertical = {
          width_padding = 0.05,
          height_padding = 1,
          preview_height = 0.5
        }
      },

      default_mappings = {
        i = {
          ["<c-j>"] = actions.move_selection_next,
          ["<c-k>"] = actions.move_selection_previous,
          ["<esc>"] = actions.close,
          ["<c-c>"] = actions.close,
          ["<c-q>"] = actions.close,
          ["<CR>"] = actions.file_edit,
          ["<c-m>"] = actions.file_edit,
          ["<C-s>"] = actions.file_split,
          ["<C-e>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          ["<C-v>"] = actions.file_vsplit,
          ["<C-t>"] = actions.file_tab
        },

        n = {
          ["<esc>"] = actions.close,
          ["<c-c>"] = actions.close,
          ["q"] = actions.close,
          ["<CR>"] = actions.file_edit,
          ["<c-m>"] = actions.file_edit
        }
      },
      width = 0.75,
      preview_cutoff = 120,
      results_height = 1,
      results_width = 0.8

      -- shorten_path = true,
      -- winblend = 10, -- help winblend
      -- winblend = {
      -- preview = 0,
      -- prompt = 20,
      -- results = 20,
      -- },
    }
  }
  require('telescope').setup(config)
end

local function setup_gitsigns()
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

local function setup_lazygit()
  vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
  vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
  vim.g.lazygit_floating_window_corner_chars = {'╭', '╮', '╰', '╯'} -- customize lazygit popup window corner characters
  vim.g.lazygit_use_neovim_remote = 0
end

local function setup_octo()
  if not utl.is_mod_available('octo') then
    api.nvim_err_writeln('octo module not available')
    return
  end

  if utl.is_mod_available('telescope') then
    require('telescope').load_extension('octo')
  end
end

local function setup_indent_blankline()
  vim.g.indent_blankline_filetype = {
    'vim', 'lua', 'c', 'python', 'cpp', 'java', 'cs', 'sh', 'ps1', 'dosbatch'
  }
  vim.g.indent_blankline_char_highlight_list = {'Comment'}
  vim.g.indent_blankline_char_list = {'¦', '┆', '┊'}
  vim.g.indent_blankline_show_first_indent_level = false
end

local function setup_git_worktree()
  -- Workflow is:
  -- mkcdir neovim
  -- git clone <neovim> --bare
  -- git worktree add master <branch>
  -- Then you'll have: neovim/{master,neovim.git,<other_workstrees>}
  if not utl.is_mod_available('git-worktree') then
    api.nvim_err_writeln('git-worktree module not available')
    return
  end

  if not utl.is_mod_available('vimp') then
    api.nvim_err_writeln('vimp module not available')
    return
  end
  local vimp = require('vimp')

  local gw = require('git-worktree')
  gw.setup({update_on_change = true, clearjumps_on_change = true})

  local function get_worktree_name(upstream)
    local wt_name = nil
    wt_name = vim.fn.input("New worktree name?\n")
    if wt_name == nil then return end

    local upstream_name = nil
    if upstream ~= nil then
      upstream_name = vim.fn.input("Branch?\n", [[upstream/master]])
    end

    return {wt_name, upstream_name}
  end

  local gwa = function() gw.create_worktree(get_worktree_name(true)) end
  local gwd = function() gw.delete_worktree(get_worktree_name()) end
  local gws = function() gw.switch_worktree(get_worktree_name()) end

  vimp.nnoremap('<leader>vwa', gwa)
  vimp.nnoremap('<leader>vwd', gwd)
  vimp.nnoremap('<leader>vws', gws)

  if utl.is_mod_available('telescope') then
    local t = require('telescope')
    t.load_extension("git_worktree")
    -- To bring up the telescope window listing your workspaces run the following

    vimp.nnoremap({'override'}, '<leader>vws',
                  t.extensions.git_worktree.git_worktrees)
    -- <Enter> - switches to that worktree
    -- <c-d> - deletes that worktree
    -- <c-D> - force deletes that worktree
  end
end

local _packer = {}
_packer._path = vim.g.std_data_path .. [[/site/pack/packer/start/packer.nvim]]
_packer._repo = [[https://github.com/wbthomason/packer.nvim]]
_packer._config = {
  ensure_dependencies = true, -- Should packer install plugin dependencies?
  package_root = require('packer.util').join_paths(vim.fn.stdpath('data'),
                                                   'site', 'pack'),
  compile_path = require('packer.util').join_paths(vim.fn.stdpath('data'),
                                                   'site', 'plugin',
                                                   'packer_compiled.vim'),
  plugin_package = 'packer', -- The default package for plugins
  max_jobs = nil, -- Limit the number of simultaneous jobs. nil means no limit
  auto_clean = true, -- During sync(), remove unused plugins
  compile_on_sync = true, -- During sync(), run packer.compile()
  disable_commands = false, -- Disable creating commands
  opt_default = false, -- Default to using opt (as opposed to start) plugins
  transitive_opt = true, -- Make dependencies of opt plugins also opt by default
  transitive_disable = true, -- Automatically disable dependencies of disabled plugins
  auto_reload_compiled = true, -- Automatically reload the compiled file after creating it.
  git = {
    cmd = 'git', -- The base command for git operations
    subcommands = { -- Format strings for git subcommands
      update = '-C %s pull --ff-only --progress --rebase=false',
      install = 'clone %s %s --depth %i --no-single-branch --progress',
      fetch = '-C %s fetch --depth 999999 --progress',
      checkout = '-C %s checkout %s --',
      update_branch = '-C %s merge --ff-only @{u}',
      current_branch = '-C %s branch --show-current',
      diff = '-C %s log --color=never --pretty=format:FMT --no-show-signature HEAD@{1}...HEAD',
      diff_fmt = '%%h %%s (%%cr)',
      get_rev = '-C %s rev-parse --short HEAD',
      get_msg = '-C %s log --color=never --pretty=format:FMT --no-show-signature HEAD -n 1',
      submodules = '-C %s submodule update --init --recursive --progress'
    },
    depth = 1, -- Git clone depth
    clone_timeout = 60 -- Timeout, in seconds, for git clones
  },
  display = {
    non_interactive = false, -- If true, disable display windows for all operations
    open_fn = nil, -- An optional function to open a window for packer's display
    open_cmd = '65vnew [packer]', -- An optional command to open a window for packer's display
    working_sym = '⟳', -- The symbol for a plugin being installed/updated
    error_sym = '✗', -- The symbol for a plugin with an error in installation/updating
    done_sym = '✓', -- The symbol for a plugin which has completed installation/updating
    removed_sym = '-', -- The symbol for an unused plugin which was removed
    moved_sym = '→', -- The symbol for a plugin which was moved (e.g. from opt to start)
    header_sym = '━', -- The symbol for the header line in packer's display
    show_all_info = true, -- Should packer show all update details automatically?
    keybindings = { -- Keybindings for the display window
      quit = 'q',
      toggle_info = '<CR>',
      prompt_revert = 'r'
    }
  },
  luarocks = {
    python_cmd = 'python' -- Set the python command to use for running hererocks
  }
}

function _packer:download()
  if vim.fn.isdirectory(self._path) ~= 0 then
    -- Already exists
    return
  end

  if vim.fn.executable('git') == 0 then
    print("Git is not in your path. Cannot download packer.nvim")
    return
  end

  local git_cmd = 'git clone ' .. self._repo .. ' --depth 1 ' .. self._path
  print("packer.nvim does not exist downloading...")
  vim.fn.system(git_cmd)
  vim.cmd('packadd packer.nvim')
end

-- Thu May 13 2021 22:42: After much debuggin, found out that config property 
-- is not working as intended because of issues in packer.nvim. See:
-- https://github.com/wbthomason/packer.nvim/issues/351
-- TL;DR: no outside of local scope function calling for config
function _packer:setup()
  local packer = nil
  if packer == nil then
    packer = require('packer')
    packer.init(self._config)
  end

  local use = packer.use
  packer.reset()

  use {'wbthomason/packer.nvim'}

  -- use {
  -- 'hoob3rt/lualine.nvim',
  -- config = line.lualine_config(),
  -- -- requires = {'kyazdani42/nvim-web-devicons', opt = true}
  -- }

  use {'svermeulen/vimpeccable'}

  use {
    'nvim-lua/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }

  -- Post-install/update hook with neovim command
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {{'p00f/nvim-ts-rainbow'}}
    -- {'romgrk/nvim-treesitter-context'} still some rough edges
  }

  -- Fri Apr 02 2021 09:08: Very slow for big files
  -- Thu Apr 08 2021 13:44: It was more treesitter's fault
  use {
    'hrsh7th/nvim-compe',
    requires = {{'hrsh7th/vim-vsnip'}, {'hrsh7th/vim-vsnip-integ'}}
  }
  -- use {
  -- 'Shougo/deoplete.nvim',
  -- run = ':UpdateRemotePlugins',
  -- requires = {
  -- {'Shougo/neco-vim'},
  -- {'Shougo/neco-syntax'},
  -- {'Shougo/context_filetype.vim'},
  -- {'ncm2/float-preview.nvim'},
  -- {'zchee/deoplete-zsh'},
  -- {'Shougo/deoplete-lsp'}
  -- },
  -- -- neosnippets set from plugin.vim
  -- config = compl.deoplete(),
  -- }

  use {
    'neovim/nvim-lspconfig',
    requires = {{'nvim-lua/lsp-status.nvim'}, {'ray-x/lsp_signature.nvim'}}
  }

  -- Use dependency and run lua function after load
  if utl.has_unix() then
    use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}}
  end

  use {'kdheepak/lazygit.nvim'}
  use {'nanotee/nvim-lua-guide'}
  use {'kyazdani42/nvim-tree.lua'}

  use {'kosayoda/nvim-lightbulb'}

  -- Depends on github cli
  if vim.fn.executable('gh') > 0 then
    use {
      'pwntester/octo.nvim',
      requires = {
        {'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'},
        {'nvim-lua/telescope.nvim'}
      }
    }
  end

  use {'lukas-reineke/indent-blankline.nvim', branch = 'lua'}

  if utl.has_unix() then use {'ThePrimeagen/git-worktree.nvim'} end

  -- Default commands
  -- key 	description
  -- "" 	open peekup window
  -- <Esc> 	close peekup window
  -- any character 	select and copy text from the corresponding " register
  -- <C-j>, <C-k> 	scroll the list up and down
  -- <Up>, <Down> 	move to next registers type
  use 'gennaro-tedesco/nvim-peekup'
  vim.g.peekup_paste_after = [[""]]

  use {'rhysd/git-messenger.vim', cmd = 'GitMessenger'}
  vim.g.git_messenger_always_into_popup = true

  use 'folke/tokyonight.nvim'
  vim.g.tokyonight_terminal_colors = true
  vim.g.tokyonight_italic_comments = true
  vim.g.tokyonight_dark_float = true
  vim.g.tokyonight_sidebars = {"qf", "terminal", "packer"}
  vim.g.tokyonight_style = "night"

  if vim.fn.executable('glow') > 0 then
    use {'npxbr/glow.nvim', cmd = 'Glow'}
    vim.cmd 'command! MarkdownPreviewGlow Glow'
  end
end

local function setup()
  _packer:download()
  if not utl.is_mod_available('packer') then
    api.nvim_err_writeln("packer.nvim module not found")
    return
  end

  _packer:setup()

  setup_telescope()
  setup_treesitter()
  compl.compe()
  require('config.lsp').set()
  if utl.has_unix() then setup_gitsigns() end
  setup_lazygit()
  require('config.plugins.tree_explorer').nvimtree_config()
  setup_lightbulb()
  if vim.fn.executable('gh') > 0 then setup_octo() end
  setup_indent_blankline()
  if utl.has_unix() then setup_git_worktree() end
end

return {setup = setup, setup_lspstatus = setup_lspstatus}
