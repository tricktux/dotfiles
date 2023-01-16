
local M = {}

M.c_max_lines = vim.fn.has('unix') > 0 and 50000 or 1000

local function disable(lang, bufnr)
  if vim.b.ts_disabled then  -- buffer result
    return vim.b.ts_disabled == 1
  end

  -- Max file size for unix files
  local max_filesize = 2097152  -- 2 * 1024 * 1024 = 2097152 = 2Mb
  if vim.fn.has("unix") <= 0 then
    -- Max file size for windows files
    max_filesize = 1048576  -- 1 * 1024 * 1024 = 1048576 = 1Mb
    if lang == "cpp" or lang == "c" then
      -- Max file size for windows cpp/c files
      max_filesize = 512000 -- 500 * 1024 = 512000 500Kb
    end
  end

  -- Disable TS for cpp window files bigger than 10kb
  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
  if ok and stats and stats.size > max_filesize then
    local msg = "[TreeSitter]: Highlight disabled, file is bigger than '" .. max_filesize / 1024 .. "Kb'"
    vim.notify(msg, vim.log.levels.WARN)
    vim.b.ts_disabled = 1
    return true
  end

  vim.b.ts_disabled = 0
  return false
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
  if vim.b.ts_disabled and vim.b.ts_disabled == 1 then
    return
  end

  local parsers = require 'nvim-treesitter.parsers'
  local lang = parsers.get_buf_lang()

  if parsers.get_parser_configs()[lang] and not parsers.has_parser(lang) then
    return
  end

  -- If this is a treesitter buf set it's options
  setup_buf_keymaps_opts()
end

M.__config = {
  -- This line will install all of them
  -- one of "all", "language", or a list of languages
  ensure_installed = {
    "c", "cpp", "python", "lua", "java", "bash", "c_sharp", "rust", "json",
    "toml", "bash", "cmake", "dockerfile", "json5", "latex", "r", "yaml",
    "vim", "markdown", "markdown_inline", "json", "make", "nix", "html", 
    "llvm", "comment", "org", "help"
  },
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,
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
    prev_selection = ',', -- (Optional) keymap to select the previous selection
    keymaps = {
      ['.'] = 'textsubjects-smart',
      [';'] = 'textsubjects-container-outer',
    }
  },
  rainbow = {
    disable = disable,
    enable = true
  }
}

function M:setup()
  if vim.fn.executable("clang") > 0 then
    require('nvim-treesitter.install').compilers = { "clang" }
  end
  local tsconf = require 'nvim-treesitter.configs'
  tsconf.setup(self.__config)
  vim.api.nvim_create_autocmd('Filetype', {
    callback = ensure_parser_installed,
    pattern = '*',
    desc = 'Ask to install treesitter',
  })
  end

return M
