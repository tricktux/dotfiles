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
    packer = require('packer')
    packer.init()
  end

  local use = packer.use
  packer.reset()

  use {'wbthomason/packer.nvim'}

  use {
    "folke/which-key.nvim",
    config = function() require('config.plugins.whichkey'):setup() end
  }

  use {'svermeulen/vimpeccable'}

  use {
    'nvim-lua/telescope.nvim',
    requires = {
      {'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'}
    },
    config = function() require('config.plugins.telescope').setup() end
  }

  -- Post-install/update hook with neovim command
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {'p00f/nvim-ts-rainbow', 'RRethy/nvim-treesitter-textsubjects'},
    -- {'romgrk/nvim-treesitter-context'} still some rough edges
    config = function() require('config.plugins.treesitter').setup() end
  }

  -- Fri Apr 02 2021 09:08: Very slow for big files
  -- Thu Apr 08 2021 13:44: It was more treesitter's fault
  use {
    'hrsh7th/nvim-compe',
    requires = {{'hrsh7th/vim-vsnip'}, {'hrsh7th/vim-vsnip-integ'}},
    config = function() require('config.plugins.completion').compe() end
  }
  use {
    'neovim/nvim-lspconfig',
    requires = {{'nvim-lua/lsp-status.nvim'}, {'ray-x/lsp_signature.nvim'}},
    config = function() require('config.lsp').set() end
  }

  use {
    'lewis6991/gitsigns.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    cond = function() return require('utils.utils').has_unix() end,
    config = function() require('config.plugins.gitsigns').setup() end
  }

  use {
    'kdheepak/lazygit.nvim',
    config = function()
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
    config = function()
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
    cond = function() return require('utils.utils').has_unix() end,
    config = function() require('config.plugins.git_worktree').setup() end
  }

  use {
    'rhysd/git-messenger.vim',
    cmd = 'GitMessenger',
    config = function() vim.g.git_messenger_always_into_popup = true end
  }

  use {
    'folke/lua-dev.nvim',
    cond = function() return vim.fn.executable('lua-language-server') > 0 end,
    config = function()
      if not require('utils.utils').is_mod_available('lspconfig') then
        api.nvim_err_writeln('lspconfig module not available')
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
  }

  use {
    'rcarriga/nvim-dap-ui',
    requires = {{"mfussenegger/nvim-dap"}, {"mfussenegger/nvim-dap-python"}},
    -- cond = function() return require('utils.utils').has_unix() end,
    config = function() require('config.plugins.dap'):setup() end
  }

  use {
    'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('neogit').setup {}
      if not require('utils.utils').is_mod_available('which-key') then
        vim.api.nvim_err_writeln('which-key module not available')
        return
      end
      -- open commit popup
      -- neogit.open({ "commit" })
      require("which-key").register {
        ["<leader>vo"] = {require('neogit').open, "neogit_open"}
      }
    end
  }

  use {
    'mizlan/iswap.nvim',
    requires = 'nvim-treesitter/nvim-treesitter',
    config = function()
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
      if not require('utils.utils').is_mod_available('which-key') then
        vim.api.nvim_err_writeln('iswap: which-key module not available')
        return
      end
      require("which-key").register {
        ["<localleader>s"] = {require('iswap').iswap, "iswap_arguments"}
      }
    end
  }

  use {
    'kristijanhusak/orgmode.nvim',
    config = function() require('config.plugins.orgmode'):setup() end
  }

  use {
    'tpope/vim-obsession',
    config = function() require('config.plugins.misc'):setup_obsession() end
  }

  -- Keep this setup last. So that it finalizes the lualine config
  use {
    'hoob3rt/lualine.nvim',
    -- requires = {'kyazdani42/nvim-web-devicons', opt = true},
    config = function() require('config.plugins.lualine'):setup() end
  }

end

function M:__set_mappings()
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('plugin.lua: which-key module not available')
    return
  end

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
  if not utl.is_mod_available('packer') then
    api.nvim_err_writeln("packer.nvim module not found")
    return
  end

  -- Setup initial lualine config. Plugins will add stuff, setup will finalize 
  -- it
  require('config.plugins.lualine'):config()
  self:__setup()
  self:__set_mappings()
end

return M
