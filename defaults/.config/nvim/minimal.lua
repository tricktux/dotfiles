---@brief Neovim's minimal.lua
---@author Reinaldo Molina <me at molina mail dot com>
---@license MIT

local function custom_runtime_pack_path(new_path)
  -- ignore default config and plugins
  vim.opt.runtimepath:remove(vim.fn.expand('~/.config/nvim'))
  vim.opt.packpath:remove(vim.fn.expand('~/.local/share/nvim/site'))

  -- append test directory
  local test_dir = new_path == nil and '/tmp/nvim-config' or new_path
  vim.opt.runtimepath:append(vim.fn.expand(test_dir))
  vim.opt.packpath:append(vim.fn.expand(test_dir))
end

local function packer_init(new_path)
  local test_dir = new_path == nil and '/tmp/nvim-config' or new_path

  -- install packer
  local install_path = test_dir .. '/pack/packer/start/packer.nvim'

  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.cmd('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    vim.cmd('packadd packer.nvim')
  end

  local packer = require('packer')

  packer.init({
    package_root = test_dir .. '/pack',
    compile_path = test_dir .. '/plugin/packer_compiled.lua',
  })
end

local function packer_load()
  local packer = require('packer')

  packer.startup(function(use)
    -- Packer can manage itself
    use('wbthomason/packer.nvim')

    packer.sync()
  end)
end

local function minimal()
  local config_dir = '/tmp/nvim-config'

  -- Do not load your config
  custom_runtime_pack_path(config_dir)

  -- Choose one?
  -- Now load either a minimal config
  -- vim.cmd[[source /tmp/init.vim]]

  -- Or load packer and some plugins
  -- packer_init(config_dir)
  -- packer_load()
end

minimal()
