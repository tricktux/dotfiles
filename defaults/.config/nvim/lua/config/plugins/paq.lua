local utl = require('utils.utils')
local api = vim.api

local M = {}
M.__path = vim.fn.stdpath('data') .. [[/site/pack/packer/start/paq-nvim]]
M.__repo = [[https://github.com/savq/paq-nvim]]

M.__plugins = {
  [1] = {
    paq = {"savq/paq-nvim"},
  },
  [2] = {
    paq = {"folke/which-key.nvim"},
    config = require('config.plugins.whichkey').setup
  },
  [3] = {
    paq = {{'nvim-lua/popup.nvim'}, {'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  },
  [4] = {
    paq = {'nvim-lua/plenary.nvim'}
  },
}


function M:__bootstrap()
  if vim.fn.empty(vim.fn.glob(self.__path)) <= 0 then
    return false
  end

  vim.fn.system {
    'git',
    'clone',
    '--depth=1',
    self.__repo,
    self.__path
  }

  vim.cmd('packadd paq-nvim')
  local paq = require('paq')
  -- Exit nvim after installing plugins
  vim.cmd('autocmd User PaqDoneInstall quit')
  -- Read and install packages
  paq(PKGS)
  paq.install()
  return true
end

function M:setup()
  if self:__bootstrap() == true then
    return
  end
  -- Load Paq
  local paq = require('paq')(PKGS)
end

return M
