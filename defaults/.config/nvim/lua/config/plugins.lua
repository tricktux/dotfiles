local utl = require('utils.utils')

local M = {}

-- Vim like plugins should be configured here
function M:__pre_load_hook()
  -- Setup initial lualine config. Plugins will add stuff, setup will finalize
  -- it
  require('config.plugins.lualine'):config()

  -- lazygit
  vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
  vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
  vim.g.lazygit_floating_window_corner_chars = {'╭', '╮', '╰', '╯'} -- customize lazygit popup window corner characters
  vim.g.lazygit_use_neovim_remote = 0
end

-- Lua like plugins can be configured after being loaded
function M:__post_load_hook()
  -- TODO: Add nice API so that plugins do not call whickey.register directly
  -- But rather insert into tables for mappings. Similar as to how you did with 
  -- lualine
  -- Which key first, so that it can be overwritten later
  require('config.plugins.whichkey'):setup()

  require('config.plugins.treesitter').setup()
  require('config.plugins.nvim-cmp').setup()
  require('config.lsp').setup()
  require('config.plugins.gitsigns').setup()
  require('config.plugins.tree_explorer').nvimtree_config()

  -- lightbulb
  vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]
  require'nvim-lightbulb'.update_lightbulb {}

  if utl.has_unix() then
    require('config.plugins.git_worktree').setup()
  end
end

function M:setup()
  self:__pre_load_hook()
  require('config.plugins.packer'):setup() -- Also setups lsp
  -- Now that plugins have been loaded configure them
  -- This also allows to keep control over in what order are plugins configured
  self:__post_load_hook()
end

return M
