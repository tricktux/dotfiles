---@brief Neovim's init.lua
---@author Reinaldo Molina <me at molina mail dot com>
---@license MIT

local home_dir = vim.loop.os_homedir()
local wikis = {
  home_dir .. '/Documents/wiki', home_dir .. '/Documents/Drive/wiki',
  home_dir .. '/External/reinaldo/resilio/wiki',
  '/mnt/samba/server/resilio/wiki'
}
local wikis_win = {
  [[D:\Seafile\KnowledgeIsPower\wiki]], [[D:\wiki]],
  [[D:\Reinaldo\Documents\src\resilio\wiki]]
}
local data_folders = {[[/sessions]], [[/ctags]]}
local cache_folders = {[[/backup]], [[/undo]]}

local function set_globals()
  -- Mon Oct 30 2017 15:24: Patched fonts depend on this option. It also needs
  -- to be here. Otherwise Alt mappings stop working.
  -- Wed Apr 06 2022 05:55: Also needs to be VimL, for some reason
  vim.cmd[[
    let mapleader = "\<Space>"
    let maplocalleader = "g"
  ]]
  -----------------------

  vim.g.dotfiles = vim.fn.has('unix') > 0
    and home_dir .. "/.config/dotfiles"
    or os.getenv("LOCALAPPDATA") .. "\\dotfiles"

  vim.g.plug_path = vim.fn.stdpath('data') .. '/site/autoload/plug.vim'
  vim.g.vim_plugins_path = vim.fn.stdpath('data') .. '/vim_plugins'

  -- Disable unnecessary providers
  -- Saves on average 3ms (on linux) :D
  vim.g.loaded_python_provider = 0
  vim.g.loaded_ruby_provider = 0
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_node_provider = 0

  if vim.fn.has('nvim-0.7') > 0 then
    -- Disable filetypes.vim and enable filetypes.lua
    vim.g.did_load_ftdetect = 1
    vim.g.do_filetype_lua = 1
  end

  local disabled_built_ins = {
    "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers", "gzip", "zip",
    "zipPlugin", "tar", "tarPlugin", "getscript", "getscriptPlugin", "vimball",
    "vimballPlugin", "2html_plugin", "logipat", "rrhelper", "spellfile_plugin"
  }

  for _, plugin in pairs(disabled_built_ins) do vim.g["loaded_" .. plugin] = 1 end
end

local function _find_dir(dirs)
  local log = require('utils.log')
  local utl = require('utils.utils')
  vim.validate {dirs = {dirs, 't'}}
  for _, dir in pairs(dirs) do
    log.trace("Potential dir: ", dir)
    if utl.isdir(dir) then
      log.trace("Found dir: ", dir)
      return dir
    end
  end

  log.trace("No dir found")
  return nil
end

local function _config_win()
  local log = require('utils.log')
  local wiki = _find_dir(wikis_win)
  log.info("wiki = ", wiki)
  if wiki ~= nil then
    vim.g.wiki_path = wiki
    -- vim.g.valid_device = 1
  end

  vim.g.browser_cmd = 'firefox.exe'

  -- Find python
  local py = vim.fn.stdpath('data') .. [[\pyvenv\Scripts]]
  if vim.fn.isdirectory(py) <= 0 then
    print('ERROR: Failed to find python venv: ' .. py)
  else
    vim.g.python3_host_prog = py .. [[\python.exe]]
  end
end

local function _config_unix()
  local log = require('utils.log')
  local wiki = _find_dir(wikis)
  log.info("wiki = ", wiki)
  if wiki ~= nil then
    vim.g.wiki_path = wiki
    -- vim.g.valid_device = 1
  end

  vim.g.browser_cmd = '/usr/bin/firefox'

  local py = vim.fn.stdpath('data') .. [[/../pyvenv/nvim/bin]]
  if vim.fn.isdirectory(py) > 0 then
    vim.g.python3_host_prog = py .. [[/python]]
  end
end

local function init_os()
  local log = require('utils.log')
  local utl = require('utils.utils')

  if utl.has_unix() then _config_unix() else _config_win() end

  -- Create needed directories if they don't exist already
  for _, folder in pairs(data_folders) do
    log.trace(folder .. " = " .. vim.fn.stdpath('data') .. folder)
    if not utl.isdir(vim.fn.stdpath('data') .. folder) then
      vim.fn.mkdir(vim.fn.stdpath('data') .. folder, "p")
    end
  end
  for _, folder in pairs(cache_folders) do
    log.trace(folder .. " = " .. vim.fn.stdpath('cache') .. folder)
    if not utl.isdir(vim.fn.stdpath('cache') .. folder) then
      vim.fn.mkdir(vim.fn.stdpath('cache') .. folder, "p")
    end
  end
end

local function main()
  local log = require('utils.log')
  log.info('--- Start Neovim Run ---')
  set_globals()

  require('utils.keymap'):set() -- Set mappings
  init_os()
  -- Rationale for plugins last:
  --  This way you can set your default mappings/options and plugins can
  --  overwrite them later, if they need to. Also get rid of all plugin
  --  specific stuff. Downside is no which-key
  require('config.mappings'):setup()
  require('config.aucmds').setup()
  require('config.plugins.packer'):setup() -- Also setups lsp
  if vim.fn["plugin#Config"]() ~= 1 then
    vim.api.nvim_err_writeln('No plugins were loaded')
  end
  vim.fn["mappings#Set"]()
  vim.fn["options#Set"]()
  vim.fn["augroup#Set"]()
  vim.fn["commands#Set"]()
end

main()
