local plg = require('config.plugin')
local maps = require('config.mappings')
local log = require('utils.log')
local utl = require('utils.utils')
local map = require('utils.keymap')
local aug = require('config.augroups')
local luv = vim.loop

local home_dir = luv.os_homedir()
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

local function _find_dir(dirs)
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
  local wiki = _find_dir(wikis_win)
  log.info("wiki = ", wiki)
  if wiki ~= nil then
    vim.g.wiki_path = wiki
    -- vim.g.valid_device = 1
  end

  vim.g.browser_cmd = 'firefox.exe'

  -- Find python
  local py = vim.g.std_data_path .. [[\pyvenv\Scripts]]
  if not vim.fn.isdirectory(py) then
    print('ERROR: Failed to find python venv: ' .. py)
  else
    vim.g.python3_host_prog = py .. [[\python.exe]]
    vim.cmd("let $PATH = '" .. py .. "' . ';' . $PATH")
  end
end

local function _config_unix()
  local wiki = _find_dir(wikis)
  log.info("wiki = ", wiki)
  if wiki ~= nil then
    vim.g.wiki_path = wiki
    -- vim.g.valid_device = 1
  end

  vim.g.browser_cmd = '/usr/bin/firefox'

  local py = vim.g.std_data_path .. [[/../pyvenv/nvim/bin]]
  if not vim.fn.isdirectory(py) then
    print('ERROR: Failed to find python venv: ' .. py)
  else
    vim.g.python3_host_prog = py .. [[/python]]
    vim.cmd("let $PATH = '" .. py .. "' . ':' . $PATH")
  end
end

local function _init()
  log.info('--- Start Neovim Run ---')

  -- Disable unnecessary providers
  -- Saves on average 3ms (on linux) :D
  vim.g.loaded_python_provider = 0
  vim.g.loaded_ruby_provider = 0
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_node_provider = 0

  local disabled_built_ins = {
    "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers", "gzip", "zip",
    "zipPlugin", "tar", "tarPlugin", "getscript", "getscriptPlugin", "vimball",
    "vimballPlugin", "2html_plugin", "logipat", "rrhelper", "spellfile_plugin"
  }

  for _, plugin in pairs(disabled_built_ins) do vim.g["loaded_" .. plugin] = 1 end

  map:set() -- Set mappings

  if utl.has_unix() then
    _config_unix()
  else
    _config_win()
  end

  -- Create needed directories if they don't exist already
  for _, folder in pairs(data_folders) do
    log.trace(folder .. " = " .. vim.g.std_data_path .. folder)
    if not utl.isdir(vim.g.std_data_path .. folder) then
      vim.fn.mkdir(vim.g.std_data_path .. folder, "p")
    end
  end
  for _, folder in pairs(cache_folders) do
    log.trace(folder .. " = " .. vim.g.std_cache_path .. folder)
    if not utl.isdir(vim.g.std_cache_path .. folder) then
      vim.fn.mkdir(vim.g.std_cache_path .. folder, "p")
    end
  end

  plg:setup() -- Also setups lsp
  maps:setup()
  aug.setup()
end

return {init = _init}
