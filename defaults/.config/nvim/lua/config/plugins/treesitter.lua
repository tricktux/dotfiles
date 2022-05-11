local utl = require('utils/utils')

local M = {}

M.c_max_lines = vim.fn.has('unix') > 0 and 50000 or 1000

function M:__disable(lang, bufnr)
  if lang ~= "cpp" or lang ~= "c" then
    return true
  end

  return vim.api.nvim_buf_line_count(bufnr) < self.c_max_lines
end

function M:setup()
  -- Mon Apr 05 2021 17:36:
  -- performance of treesitter in large files is very low.
  -- Keep as little modules enabled as possible.
  -- Also no status line
  -- No extra modules. Looking at you rainbow
  require('nvim-treesitter.install').compilers = { "clang" }
  -- local ts = require'nvim-treesitter'
  local tsconf = require 'nvim-treesitter.configs'

  local config = {
    -- This line will install all of them
    -- one of "all", "language", or a list of languages
    ensure_installed = {
      "c", "cpp", "python", "lua", "java", "bash", "c_sharp", "rust", "json",
      "toml", "bash", "cmake", "dockerfile", "json5", "latex", "r", "yaml",
      "vim", "markdown", "json", "make", "nix", "html", "llvm", "comment"
    },
    highlight = {
      disable = self.__disable,
      enable = true, -- false will disable the whole extension
      additional_vim_regex_highlighting = false,
    },
    indent = {
      disable = self.__disable,
      enable = true
    },
    iswap = {
      disable = self.__disable,
      enable = true
    },
    nvimGPS = {
      disable = self.__disable,
      enable = true}
    ,
    textsubjects = {
      disable = self.__disable,
      enable = true,
      keymaps = {
        ['.'] = 'textsubjects-smart',
        [';'] = 'textsubjects-big',
      }
    },
    rainbow = {
      disable = self.__disable,
      enable = true
    }
  }

  tsconf.setup(config)
  vim.cmd[[
    set foldmethod=expr
    set foldexpr=nvim_treesitter#foldexpr()
  ]]
end

return M
