-- File:           plugin.lua
-- Description:    Used to configure different plugins
-- Author:		    Reinaldo Molina
-- Email:          me at molinamail dot com
-- Created:        Tue Sep 08 2020 22:20
-- Last Modified:  Tue Sep 08 2020 22:20
local utl = require('utils.utils')
local api = vim.api

local M = {}
M._path = vim.g.std_data_path .. [[/site/pack/packer/start/packer.nvim]]
M._repo = [[https://github.com/wbthomason/packer.nvim]]
M._config = {
  compile_path = require('packer.util').join_paths(vim.fn.stdpath('data'),
                                                   'site', 'plugin',
                                                   'packer_compiled.vim'),
}

function M:download()
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
function M:__setup()
  local packer = nil
  if packer == nil then
    packer = require('packer')
    packer.init(self._config)
  end

  local use = packer.use
  packer.reset()

  use {'wbthomason/packer.nvim'}

  use {
    "folke/which-key.nvim",
    config = function() require('config.plugins.whichkey'):setup() end,
  }

  use {'svermeulen/vimpeccable'}

  use {
    'nvim-lua/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    config = function() require('config.plugins.telescope').setup() end,
  }

  -- Post-install/update hook with neovim command
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {'p00f/nvim-ts-rainbow', 'RRethy/nvim-treesitter-textsubjects'},
    -- {'romgrk/nvim-treesitter-context'} still some rough edges
    config = function() require('config.plugins.treesitter').setup() end,
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
    config = function()
      require('telescope').load_extension('octo')
    end,
    cond = function() return vim.fn.executable('gh') > 0 end
  }

  use {
    'lukas-reineke/indent-blankline.nvim', 
    branch = 'lua',
    config = function()
      vim.g.indent_blankline_filetype = {
        'vim', 'lua', 'c', 'python', 'cpp', 'java', 'cs', 'sh', 'ps1', 'dosbatch'
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
    config = function()
      vim.g.git_messenger_always_into_popup = true
    end
  }

  use {
    'folke/tokyonight.nvim',
    diable = true,  -- Missing too many highlights
    config = function()
      vim.g.tokyonight_terminal_colors = true
      vim.g.tokyonight_italic_comments = true
      vim.g.tokyonight_dark_float = true
      vim.g.tokyonight_sidebars = {"qf", "terminal", "packer"}
      vim.g.tokyonight_style = "night"
    end,
  }

  use {
    'npxbr/glow.nvim', 
    cmd = 'Glow',
    cond = function() return vim.fn.executable('glow') > 0 end,
    config = function()
      vim.cmd 'command! MarkdownPreviewGlow Glow'
    end
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
          plugins = true -- installed opt or start plugins in packpath
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
    requires = {{"mfussenegger/nvim-dap", opt = true}},
    cond = function() return require('utils.utils').has_unix() end,
    config = function() require('config.plugins.dap').setup() end
  }

  use {
    'TimUntersberger/neogit', 
    requires = 'nvim-lua/plenary.nvim',
    config = function() 
      require('neogit').setup {}
      if not utl.is_mod_available('which-key') then
        api.nvim_err_writeln('which-key module not available')
        return
      end
      local wk = require("which-key")
      -- open using defaults
      -- neogit.open()
      -- open commit popup
      -- neogit.open({ "commit" })
      wk.register{["<leader>vo"] = {neogit.open, "neogit_open"}}
    end
  }
end

function M:setup()
  self:download()
  if not utl.is_mod_available('packer') then
    api.nvim_err_writeln("packer.nvim module not found")
    return
  end

  self:__setup()
end

return M
