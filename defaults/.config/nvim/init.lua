---@brief Neovim's init.lua
--
---@author Reinaldo Molina <me at molina mail dot com>
---@license MIT

local home = vim.loop.os_homedir()
local data_folders = { [[/sessions]], [[/ctags]] }
local cache_folders = { [[/backup]], [[/undo]] }
local fs = vim.fs

local function set_globals()
  -- Mon Oct 30 2017 15:24: Patched fonts depend on this option. It also needs
  -- to be here. Otherwise Alt mappings stop working.
  -- Wed Apr 06 2022 05:55: Also needs to be VimL, for some reason
  vim.cmd([[
    let mapleader = "\<Space>"
    let maplocalleader = "g"
  ]])
  -----------------------

  -- https://github.com/neovim/neovim/issues/14090#issuecomment-1237820552
  vim.g.ts_highlight_lua = true
  -- Disable unnecessary providers
  -- Saves on average 3ms (on linux) :D
  vim.g.loaded_python_provider = 0
  vim.g.loaded_ruby_provider = 0
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_node_provider = 0

  if vim.fn.has("nvim-0.8") == 0 then
    -- Disable filetypes.vim and enable filetypes.lua
    vim.g.did_load_filetypes = 0
    vim.g.do_filetype_lua = 1
  end

  vim.g.sessions_path = vim.fn.stdpath("state") .. [[/sessions]]

  local disabled_built_ins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "matchit",
    "matchparen",
    "tohtml",
    "tutor",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    -- "spellfile_plugin",
  }

  for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
  end
end

local function _config_win()
  vim.cmd([[silent! call serverstart('\\.\pipe\nvim-pipe-88888')]])

  vim.g.dotfiles = fs.joinpath(os.getenv("APPDATA"), "dotfiles")
  -- Find python
  local py = fs.joinpath(vim.fn.stdpath("data"), [[pyvenv\Scripts]])
  if vim.loop.fs_stat(py) == nil then
    vim.api.nvim_err_writeln("ERROR: Failed to find python venv: " .. py)
  else
    vim.g.python3_host_prog = fs.joinpath(py, [[python.exe]])
  end
end

local function _config_unix()
  vim.cmd([[silent! call serverstart('/tmp/nvim.socket')]])

  vim.g.dotfiles = fs.joinpath(home, ".config/dotfiles")
  local py = fs.normalize("$XDG_DATA_HOME/pyvenv/nvim/bin/python")
  if vim.loop.fs_stat(py) ~= nil then
    vim.g.python3_host_prog = py
  else
    vim.api.nvim_err_writeln("ERROR: Failed to find python venv: " .. py)
  end
end

local function firenvim()
  vim.g.firenvim_config = {
    localSettings = {
      [".*"] = {
        takeover = "never",
      },
    },
  }
end

local function init_os()
  local log = require("utils.log")

  if vim.fn.has("unix") > 0 then
    _config_unix()
  else
    _config_win()
  end

  -- Create needed directories if they don't exist already
  for _, folder in pairs(data_folders) do
    vim.fn.mkdir(fs.joinpath(vim.fn.stdpath("data"), folder), "p")
  end
  for _, folder in pairs(cache_folders) do
    vim.fn.mkdir(fs.joinpath(vim.fn.stdpath("cache"), folder), "p")
  end
end

local function main()
  vim.loader.enable()
  local log = require("utils.log")
  log.info("--- Start Neovim Run ---")
  set_globals()

  init_os()
  -- Initialize guis specific config vars here
  firenvim()
  -- Rationale for plugins last:
  --  This way you can set your default mappings/options and plugins can
  --  overwrite them later, if they need to. Also get rid of all plugin
  --  specific stuff. Downside is no which-key
  vim.fn["mappings#Set"]()
  require("mappings"):setup()
  require("aucmds").setup()
  vim.fn["options#Set"]()
  vim.fn["commands#Set"]()
  require("options"):setup()
  -- setup wiki early so that path is available
  require("plugin.wiki"):setup()
  require("plugin.termdebug"):init()
  require("lazyr").setup()
end

main()
-- vim.cmd('source ' .. home_dir .. [[/.config/nvim/minimal.lua]])
