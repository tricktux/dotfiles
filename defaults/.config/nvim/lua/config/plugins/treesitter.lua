
local M = {}

M.c_max_lines = vim.fn.has('unix') > 0 and 50000 or 1000

local function disable(lang, bufnr)
  if lang ~= "cpp" or lang ~= "c" then
    return true
  end

  local __disabled = vim.api.nvim_buf_line_count(bufnr) < M.c_max_lines
  if __disabled then
    vim.b.ts_disabled = 1
  end
  return __disabled
end

local function setup_buf_keymaps_opts()
  local opts = {silent = true, buffer = true, desc = 'treesitter_toggle_buffer'}
  vim.keymap.set('n', '<leader>tt', [[<cmd>TSBufToggle<cr>]], opts)
  -- Only overwrite settings when instructed
  -- The best place to set these variables is after/ftplugin
  if vim.b.did_fold_settings == nil then
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
  end
  if vim.b.did_indent_settings == nil then
    vim.opt_local.indentexpr = "nvim_treesitter#indent()"
  end
end

local function ensure_parser_installed()
  if vim.b.ts_asked_already or vim.b.ts_disabled then
    return
  end

  vim.b.ts_asked_already = true

  local parsers = require 'nvim-treesitter.parsers'
  local lang = parsers.get_buf_lang()

  if not parsers.get_parser_configs()[lang] or parsers.has_parser(lang) then
    setup_buf_keymaps_opts()
    return
  end

  vim.schedule_wrap(function()
    vim.ui.select({ 'Y', 'n' }, {
      prompt = 'Install treesitter parser for '..lang.. ':',
    }, 
    function(choice)
      if choice == 'n' then
        return
      end
      vim.cmd('TSInstall '..lang)
      setup_buf_keymaps_opts()
    end)
  end)()
end

M.__config = {
  -- This line will install all of them
  -- one of "all", "language", or a list of languages
  ensure_installed = {
    "c", "cpp", "python", "lua", "java", "bash", "c_sharp", "rust", "json",
    "toml", "bash", "cmake", "dockerfile", "json5", "latex", "r", "yaml",
    "vim", "markdown", "json", "make", "nix", "html", "llvm", "comment", "org"
  },
  highlight = {
    disable = disable,
    enable = true, -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    disable = disable,
    enable = false  -- superseded by textsubjects
  },
  indent = {
    disable = disable,
    enable = true
  },
  iswap = {
    disable = disable,
    enable = true
  },
  nvimGPS = {
    disable = disable,
    enable = true
  },
  textsubjects = {
    disable = disable,
    enable = true,
    keymaps = {
      ['.'] = 'textsubjects-smart',
      [';'] = 'textsubjects-big',
    }
  },
  rainbow = {
    disable = disable,
    enable = true
  }
}

function M:setup()
  -- Mon Apr 05 2021 17:36:
  -- performance of treesitter in large files is very low.
  -- Keep as little modules enabled as possible.
  -- Also no status line
  -- No extra modules. Looking at you rainbow
  require('nvim-treesitter.install').compilers = { "clang" }
  local tsconf = require 'nvim-treesitter.configs'
  tsconf.setup(self.__config)
  vim.api.nvim_create_autocmd('Filetype', {
    callback = ensure_parser_installed,
    pattern = '*',
    desc = 'Ask to install treesitter',
  })
  end

return M
