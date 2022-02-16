-- File:           plugin.lua
-- Description:    Used to configure different plugins
-- Author:		    Reinaldo Molina
-- Email:          me at molinamail dot com
-- Created:        Tue Sep 08 2020 22:20
-- Last Modified:  Tue Sep 08 2020 22:20
local utl = require('utils.utils')
local api = vim.api

local M = {}
M.__path = vim.g.std_data_path .. [[/site/pack/packer/start/packer.nvim]]
M.__repo = [[https://github.com/wbthomason/packer.nvim]]

function M:download()
  if vim.fn.isdirectory(self.__path) ~= 0 then
    -- Already exists
    return
  end

  if vim.fn.executable('git') == 0 then
    print("Git is not in your path. Cannot download packer.nvim")
    return
  end

  local git_cmd = 'git clone ' .. self.__repo .. ' --depth 1 ' .. self.__path
  print("packer.nvim does not exist downloading...")
  vim.fn.system(git_cmd)
  vim.cmd('packadd packer.nvim')
end

-- Thu May 13 2021 22:42: After much debuggin, found out that config property
-- is not working as intended because of issues in packer.nvim. See:
-- https://github.com/wbthomason/packer.nvim/issues/351
-- TL;DR: no outside of local scope function calling for config
function M:__setup()
  local packer = nil
  if packer == nil then
    local jobs = utl.has_unix() and nil or 5
    packer = require('packer')
    packer.init({max_jobs = jobs, log = "trace"})
  end

  local use = packer.use
  packer.reset()

  use {'wbthomason/packer.nvim'}

  use {
    "folke/which-key.nvim",
    config = function() require('config.plugins.whichkey'):setup() end
  }

  use {
    'nvim-lua/telescope.nvim',
    after = 'which-key.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    config = function() require('config.plugins.telescope').setup() end
  }

  -- Post-install/update hook with neovim command
  use {
    'nvim-treesitter/nvim-treesitter',
    after = 'which-key.nvim',
    run = ':TSUpdate',
    requires = {'p00f/nvim-ts-rainbow', 'RRethy/nvim-treesitter-textsubjects'},
    -- {'romgrk/nvim-treesitter-context'} still some rough edges
    config = function() require('config.plugins.treesitter').setup() end
  }

  use {
    'hrsh7th/nvim-cmp',
    after = 'LuaSnip',
    requires = {
      'hrsh7th/cmp-buffer', 'hrsh7th/cmp-nvim-lua', 'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path', 'hrsh7th/cmp-calc', 'ray-x/cmp-treesitter',
      'quangnguyen30192/cmp-nvim-tags', 'onsails/lspkind-nvim'
    },
    config = function() require('config.plugins.nvim-cmp').setup() end
  }

  use {
    'neovim/nvim-lspconfig',
    requires = {{'ray-x/lsp_signature.nvim'}, {'j-hui/fidget.nvim'}},
    config = function() require('config.lsp').setup() end
  }

  use {
    'lewis6991/gitsigns.nvim',
    after = 'which-key.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = function() require('config.plugins.gitsigns').setup() end
  }

  use {
    'kdheepak/lazygit.nvim',
    setup = function()
      vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
      vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
      vim.g.lazygit_floating_window_corner_chars = {'╭', '╮', '╰', '╯'} -- customize lazygit popup window corner characters
      vim.g.lazygit_use_neovim_remote = 0
    end
  }

  use {'nanotee/nvim-lua-guide'}
  use {
    'kyazdani42/nvim-tree.lua',
    config = function()
      require('config.plugins.tree_explorer').nvimtree_config()
    end
  }

  use {
    'kosayoda/nvim-lightbulb',
    config = function()
      vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]
      require'nvim-lightbulb'.update_lightbulb {}
    end
  }

  -- Depends on github cli
  use {
    'pwntester/octo.nvim',
    requires = {
      {'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'},
      {'nvim-lua/telescope.nvim'}
    },
    config = function() require('telescope').load_extension('octo') end,
    cond = function() return vim.fn.executable('gh') > 0 end
  }

  use {
    'lukas-reineke/indent-blankline.nvim',
    setup = function()
      vim.g.indent_blankline_filetype = {
        'vim', 'lua', 'c', 'python', 'cpp', 'java', 'cs', 'sh', 'ps1',
        'dosbatch'
      }
      vim.g.indent_blankline_char_highlight_list = {'Comment'}
      vim.g.indent_blankline_char_list = {'¦', '┆', '┊'}
      vim.g.indent_blankline_show_first_indent_level = false
    end
  }

  use {
    'ThePrimeagen/git-worktree.nvim',
    after = {'which-key.nvim', 'telescope.nvim'},
    requires = {{'nvim-lua/telescope.nvim'}, {'folke/which-key.nvim'}},
    cond = function() return require('utils.utils').has_unix() end,
    config = function() require('config.plugins.git_worktree').setup() end
  }

  use {
    'rhysd/git-messenger.vim',
    cmd = 'GitMessenger',
    setup = function() vim.g.git_messenger_always_into_popup = true end,
    config = function() require('config.plugins.misc').config_git_messenger() end
  }

  use {
    'folke/lua-dev.nvim',
    cond = function() return vim.fn.executable('lua-language-server') > 0 end,
    config = function() require('config.plugins.misc').setup_luadev() end
  }

  if utl.has_unix() then
    use {
      'rcarriga/nvim-dap-ui',
      requires = {
        {"mfussenegger/nvim-dap"}, {"mfussenegger/nvim-dap-python"},
        {'theHamsta/nvim-dap-virtual-text'}
      },
      config = function() require('config.plugins.dap'):setup() end
    }
  end

  use {
    'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim',
    disable = true,
    config = function() require('config.plugins.misc').setup_neogit() end
  }

  use {
    'mizlan/iswap.nvim',
    after = {'which-key.nvim', 'nvim-treesitter'},
    requires = 'nvim-treesitter/nvim-treesitter',
    config = function() require('config.plugins.misc').config_iswap() end
  }

  use {
    'kristijanhusak/orgmode.nvim',
    disable = true,
    config = function() require('config.plugins.orgmode'):setup() end
  }

  use {
    'majutsushi/tagbar',
    cmd = 'Tagbar',
    setup = function()
      vim.g.tagbar_ctags_bin = 'ctags'
      vim.g.tagbar_autofocus = 1
      vim.g.tagbar_show_linenumbers = 2
      vim.g.tagbar_map_togglesort = 'r'
      vim.g.tagbar_map_nexttag = '<c-j>'
      vim.g.tagbar_map_prevtag = '<c-k>'
      vim.g.tagbar_map_openallfolds = '<c-n>'
      vim.g.tagbar_map_closeallfolds = '<c-c>'
      vim.g.tagbar_map_togglefold = '<c-x>'
      vim.g.tagbar_autoclose = 1
    end
  }

  use {
    'juneedahamed/svnj.vim',
    cmd = {'SVNStatus', 'SVNCommit'},
    setup = function()
      vim.g.svnj_allow_leader_mappings = 0
      vim.g.svnj_cache_dir = vim.g.std_cache_path
      vim.g.svnj_browse_cache_all = 1
      vim.g.svnj_custom_statusbar_ops_hide = 0
      vim.g.svnj_browse_cache_max_cnt = 50
      vim.g.svnj_custom_fuzzy_match_hl = 'Directory'
      vim.g.svnj_custom_menu_color = 'Question'
      vim.g.svnj_fuzzy_search = 1
    end
  }

  use {
    'PProvost/vim-ps1',
    ft = 'ps1',
    cond = function() return require('utils.utils').has_win() end
  }

  use {'matze/vim-ini-fold', ft = 'dosini'}

  use {
    'chrisbra/csv.vim',
    ft = 'csv',
    setup = function()
      vim.g.no_csv_maps = 1
      vim.g.csv_strict_columns = 1
    end
  }

  -- Good for folding markdown and others
  use {'fourjay/vim-flexagon', ft = 'markdown'}

  -- Extra syntax
  use {
    'PotatoesMaster/i3-vim-syntax',
    cond = function() return require('utils.utils').has_unix() end
  }
  use {'elzr/vim-json', ft = 'json'}
  use {'aklt/plantuml-syntax', ft = 'plantuml'}
  use {'MTDL9/vim-log-highlighting', ft = 'log'}
  use {'alepez/vim-gtest', ft = 'cpp'}
  use {'neomutt/neomutt.vim', ft = 'muttrc'}
  use {'fladson/vim-kitty'}
  use 'editorconfig/editorconfig-vim'

  use {
    'chaoren/vim-wordmotion',
    setup = function()
      vim.g.wordmotion_mappings = {
        w = 'L',
        b = 'H',
        e = '',
        W = '',
        B = '',
        E = '',
        ['ge'] = '',
        ['aw'] = '',
        ['iw'] = '',
        ['<C-R><C-W>'] = ''
      }
    end
  }

  use {
    'mhinz/vim-startify',
    setup = function()
      vim.g.startify_session_dir = vim.g.std_data_path .. '/sessions/'

      vim.g.startify_lists = {
        {['type'] = 'sessions', ['header'] = {'   Sessions'}},
        {['type'] = 'files', ['header'] = {'   MRU'}}
      }
      vim.g.startify_change_to_dir = 0
      vim.g.startify_session_sort = 1
      vim.g.startify_session_number = 10
    end
  }

  use {
    'NLKNguyen/papercolor-theme',
    setup = function() require('config.plugins.misc'):setup_papercolor() end
  }

  use {
    'jiangmiao/auto-pairs',
    setup = function()
      -- Really annoying option
      vim.g.AutoPairsFlyMode = 0
      vim.g.AutoPairsShortcutToggle = ''
      vim.g.AutoPairsShortcutFastWrap = ''
      vim.g.AutoPairsShortcutJump = ''
      vim.g.AutoPairsShortcutBackInsert = ''
    end
  }

  use {'tpope/vim-fugitive', cmd = 'Git'}
  use 'tpope/vim-repeat'
  use 'tpope/vim-surround'
  use {'tpope/vim-dispatch', setup = function() vim.g.dispatch_no_maps = 1 end}
  use {
    'radenling/vim-dispatch-neovim',
    cond = function() return vim.fn.has('nvim') > 0 end
  }
  use {
    'tpope/vim-obsession',
    setup = function() require('config.plugins.misc'):setup_obsession() end
  }

  use {
    'tricktux/pomodoro.vim',
    setup = function() require('config.plugins.misc'):setup_pomodoro() end
  }

  use {
    'kassio/neoterm',
    after = 'which-key.nvim',
    setup = function() require('config.plugins.misc'):setup_neoterm() end,
    config = function() require('config.plugins.misc'):config_neoterm() end
  }

  use {'ferrine/md-img-paste.vim', ft = 'markdown'}

  use {
    'gcmt/taboo.vim',
    config = function() vim.cmd [[nnoremap <leader>tr :TabooRename ]] end
  }

  use {
    'ironhouzi/starlite-nvim',
    config = function() require('config.plugins.misc'):setup_starlite() end
  }

  use {
    'justinmk/vim-sneak',
    setup = function() require('config.plugins.misc'):setup_sneak() end
  }

  use {
    'kazhala/close-buffers.nvim',
    after = 'which-key.nvim',
    config = function() require('config.plugins.misc'):setup_bdelete() end
  }

  use {
    'MattesGroeger/vim-bookmarks',
    after = 'which-key.nvim',
    setup = function() require('config.plugins.misc'):setup_bookmarks() end,
    config = function() require('config.plugins.misc'):config_bookmarks() end
  }

  use 'whiteinge/diffconflicts'

  use {'aquach/vim-http-client', cmd = 'HTTPClientDoRequest'}

  use {
    'jsfaint/gen_tags.vim', -- Not being suppoprted anymore
    setup = function()
      vim.g["gen_tags#cache_dir"] = vim.g.std_cache_path .. '/ctags/'
      vim.g["gen_tags#use_cache_dir"] = 1
      vim.g["loaded_gentags#gtags"] = 1 -- Disable gtags
      vim.g["gen_tags#gtags_default_map"] = 0
      vim.g["gen_tags#statusline"] = 0

      vim.g["gen_tags#ctags_auto_gen"] = 1
      vim.g["gen_tags#ctags_prune"] = 1
      vim.g["gen_tags#ctags_opts"] = '--sort=no --append'
    end
  }

  use {
    'lambdalisue/suda.vim',
    cond = function() return require('utils.utils').has_unix() end
  }

  use {
    'chr4/nginx.vim',
    cond = function() return require('utils.utils').has_unix() end
  }

  use {
    'jamessan/vim-gnupg',
    cond = function() return vim.fn.executable('gpg') > 0 end
  }

  use {
    's1n7ax/nvim-comment-frame',
    after = {'which-key.nvim', 'nvim-treesitter'},
    requires = "nvim-treesitter/nvim-treesitter",
    config = function() require('config.plugins.misc'):setup_comment_frame() end
  }

  use {
    'b3nj5m1n/kommentary',
    setup = function() vim.g.kommentary_create_default_mappings = false end,
    config = function() require('config.plugins.misc'):config_kommentary() end
  }

  use {
    'beauwilliams/focus.nvim',
    config = function() require('config.plugins.misc'):config_focus() end
  }

  use {
    "folke/zen-mode.nvim",
    cmd = 'ZenMode',
    after = 'which-key.nvim',
    config = function() require('config.plugins.misc'):setup_zen_mode() end
  }

  --[[ use {
    'camspiers/lens.vim',
    requires = 'camspiers/animate.vim',
    config = function() require('config.plugins.misc'):setup_lens() end
  } ]]

  use {'weilbith/nvim-code-action-menu', cmd = 'CodeActionMenu'}

  use {
    'sindrets/diffview.nvim',
    cmd = {'DiffviewOpen', 'DiffviewFileHistory'},
    config = function() require('config.plugins.misc'):setup_diffview() end
  }

  use {
    "SmiteshP/nvim-gps",
    after = 'nvim-treesitter',
    requires = "nvim-treesitter/nvim-treesitter",
    config = function() require('config.plugins.misc'):setup_gpsnvim() end
  }

  use {
    "ahmedkhalf/project.nvim",
    after = 'telescope.nvim',
    requires = {'nvim-lua/telescope.nvim'},
    config = function() require('config.plugins.misc'):config_project() end
  }

  --[[ use {
    'jose-elias-alvarez/null-ls.nvim',
    config = function() require('config.plugins.null-ls'):setup() end
  } ]]

  use {
    'L3MON4D3/LuaSnip',
    after = 'which-key.nvim',
    requires = {'rafamadriz/friendly-snippets', 'honza/vim-snippets'},
    config = function() require('config.plugins.luasnip'):config() end
  }

  use {
    'knubie/vim-kitty-navigator',
    after = 'focus.nvim',
    run = 'cp ./*.py ~/.config/kitty/',
    setup = function() vim.g.kitty_navigator_no_mappings = 1 end,
    config = function()
      require('config.plugins.misc'):config_kitty_navigator()
    end,
    cond = function() return require('utils.utils').has_unix() end
  }

  -- Keep this setup last. So that it finalizes the lualine config
  use {'nvim-lualine/lualine.nvim'}
end

function M:__set_mappings()
  local wk = require("which-key")
  local opts = {prefix = '<leader>P'}
  local plug = {
    name = 'Plug',
    i = {'<cmd>PlugInstall<cr>', 'install'},
    u = {'<cmd>PlugUpdate<cr>', 'update'},
    r = {'<cmd>UpdateRemotePlugins<cr>', 'update_remote_plugins'},
    g = {'<cmd>PlugUpgrade<cr>', 'upgrade_vim_plug'},
    s = {'<cmd>PlugSearch<cr>', 'search'},
    l = {'<cmd>PlugClean<cr>', 'clean'}
  }
  local p = require('packer')
  local packer = {
    name = 'Packer',
    c = {p.compile, 'compile'},
    u = {p.update, 'update'},
    r = {'<cmd>UpdateRemotePlugins<cr>', 'update_remote_plugins'},
    i = {p.install, 'install'},
    s = {p.sync, 'sync'},
    a = {p.status, 'status'},
    l = {p.clean, 'clean'}
  }
  local mappings = {name = 'plugins', l = plug, a = packer}
  wk.register(mappings, opts)
end

function M:setup()
  self:download()
  -- Ensure lualine is the first to setup and last to config
  require('config.plugins.lualine'):setup()
  self:__setup()
  self:__set_mappings()
  require('config.plugins.lualine'):config()
end

return M
