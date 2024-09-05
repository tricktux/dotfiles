local M = {}

M.c_max_lines = vim.fn.has('unix') > 0 and 50000 or 1000

local function disable(lang, bufnr)
  if vim.b.ts_disabled then -- buffer result
    return vim.b.ts_disabled == 1
  end

  -- Max file size for unix files
  local max_filesize = 262144 -- 256 * 1024 Kb

  local stat = vim.fn.has('0.10.0') > 0 and vim.uv.fs_stat or vim.loop.fs_stat
  local ok, stats = pcall(stat, vim.api.nvim_buf_get_name(bufnr))
  if ok and stats and stats.size > max_filesize then
    local msg = "[TreeSitter]: Highlight disabled, file is bigger than '"
      .. max_filesize / 1024
      .. "Kb'"
    vim.notify(msg, vim.log.levels.WARN)
    vim.b.ts_disabled = 1
    return true
  end

  vim.b.ts_disabled = 0
  return false
end

M.__config = {
  -- This line will install all of them
  -- one of "all", "language", or a list of languages
  ensure_installed = {},
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = vim.g.advanced_plugins == 1 and true or false,
  highlight = {
    disable = disable,
    enable = true, -- false will disable the whole extension
    -- Required for spellcheck, some LaTex highlights and code block highlights that do not have ts grammar
    additional_vim_regex_highlighting = { 'org' },
  },
  incremental_selection = {
    enable = false, -- superseded by textsubjects
  },
  indent = {
    disable = disable,
    enable = true,
  },
  iswap = {
    disable = disable,
    enable = true,
  },
  textsubjects = {
    disable = disable,
    enable = true,
    prev_selection = ',', -- (Optional) keymap to select the previous selection
    keymaps = {
      ['.'] = 'textsubjects-smart',
      [';'] = 'textsubjects-container-outer',
    },
  },
  rainbow = {
    disable = disable,
    enable = true,
  },
}

function M:setup()
  if vim.fn.executable('clang') > 0 then
    require('nvim-treesitter.install').compilers = { 'clang' }
  end
  local tsconf = require('nvim-treesitter.configs')
  tsconf.setup(self.__config)
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPost',
    version = false, -- last release is way too old and doesn't work on Windows
    build = ':TSUpdate',
    init = function()
      local opts = { silent = true, desc = 'treesitter_toggle_buffer' }
      vim.keymap.set('n', '<leader>tt', [[<cmd>TSBufToggle highlight rainbow incremental_selection iswap indent<cr>]], opts)
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.opt.indentexpr = 'nvim_treesitter#indent()'
    end,
    config = function()
      M:setup()
    end,
  },
  {
    'p00f/nvim-ts-rainbow',
    event = 'BufReadPost',
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },
  {
    'RRethy/nvim-treesitter-textsubjects',
    event = 'BufReadPost',
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPost',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
        -- For all filetypes
        -- Note that setting an entry here replaces all other patterns for this entry.
        -- By setting the 'default' entry below, you can control which nodes you want to
        -- appear in the context window.
        default = {
          'class',
          'function',
          'method',
          'for',
          'while',
          'if',
          'switch',
          'case',
          'interface',
          'struct',
          'enum',
        },
        -- Patterns for specific filetypes
        -- If a pattern is missing, *open a PR* so everyone can benefit.
        tex = {
          'chapter',
          'section',
          'subsection',
          'subsubsection',
        },
        haskell = {
          'adt',
        },
        rust = {
          'impl_item',
        },
        terraform = {
          'block',
          'object_elem',
          'attribute',
        },
        scala = {
          'object_definition',
        },
        vhdl = {
          'process_statement',
          'architecture_body',
          'entity_declaration',
        },
        markdown = {
          'section',
        },
        elixir = {
          'anonymous_function',
          'arguments',
          'block',
          'do_block',
          'list',
          'map',
          'tuple',
          'quoted_content',
        },
        json = {
          'pair',
        },
        typescript = {
          'export_statement',
        },
        yaml = {
          'block_mapping_pair',
        },
      },
      exact_patterns = {
        -- Example for a specific filetype with Lua patterns
        -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
        -- exactly match "impl_item" only)
        -- rust = true,
      },

      -- [!] The options below are exposed but shouldn't require your attention,
      --     you can safely ignore them.

      zindex = 20, -- The Z-index of the context window
      mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
    },
  },
  {
    'mizlan/iswap.nvim',
    keys = {
      {
        '<leader>rSn',
        [[<cmd>ISwapNode<cr>]],
        desc = 'swap_node',
      },
      {
        '<leader>rw',
        [[<cmd>ISwapWith<cr>]],
        desc = 'swap_with',
      },
      {
        '<leader>rSl',
        [[<cmd>ISwapNodeWithRight<cr>]],
        desc = 'swap_with_right',
      },
      {
        '<leader>rSh',
        [[<cmd>ISwapNodeWithLeft<cr>]],
        desc = 'swap_with_left',
      },
    },
    opts = {},
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },
  {
    'danymat/neogen',
    keys = {
      {
        '<leader>rD',
        function()
          require('neogen').generate()
        end,
        desc = 'generate_neogen',
      },
      {
        '<leader>rdf',
        function()
          require('neogen').generate({ type = 'func' })
        end,
        desc = 'generate_neogen_function',
      },
      {
        '<leader>rdc',
        function()
          require('neogen').generate({ type = 'class' })
        end,
        desc = 'generate_neogen_class',
      },
      {
        '<leader>rdi',
        function()
          require('neogen').generate({ type = 'file' })
        end,
        desc = 'generate_neogen_file',
      },
      {
        '<leader>rdt',
        function()
          require('neogen').generate({ type = 'type' })
        end,
        desc = 'generate_neogen_type',
      },
    },
    opts = {
      enabled = true,
      snippet_engine = 'luasnip',
      languages = {
        csharp = {
          template = {
            annotation_convention = 'xmldoc',
          },
        },
      },
    },
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },
}
