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
    color = {fg = line.colors.blue, gui = 'bold'}
  }
end

return M
