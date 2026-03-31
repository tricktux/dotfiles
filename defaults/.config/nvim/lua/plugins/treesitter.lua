local M = {}

local max_filesize = 262144 -- 256 KB

local function should_disable(buf)
  if vim.fn.has('unix') > 0 then
    return false
  end

  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  if ok and stats and stats.size > max_filesize then
    vim.notify("[TreeSitter] Disabled (file too large)", vim.log.levels.WARN)
    vim.treesitter.stop(buf)
    return true
  end

  return false
end

function M:setup()
  -- install parsers (like kickstart)
  -- TODO: Fix this
  -- require('nvim-treesitter').install({
  --   'lua',
  --   'vim',
  --   'vimdoc',
  --   'query',
  --   'bash',
  --   'c',
  --   'html',
  --   'markdown',
  --   'markdown_inline',
  -- })

  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf = args.buf
      if should_disable(buf) then
        return
      end

      local ft = args.match
      local lang = vim.treesitter.language.get_lang(ft)
      if not lang then
        return
      end

      if not vim.treesitter.language.add(lang) then
        return
      end

      vim.treesitter.start(buf, lang)

      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPost',
    version = false, -- last release is way too old and doesn't work on Windows
    build = ':TSUpdate',
    branch = 'main',
    init = function()
      local opts = { silent = true, desc = 'treesitter_toggle_buffer' }
      vim.keymap.set(
        'n',
        '<leader>tt',
        [[<cmd>TSBufToggle highlight rainbow incremental_selection iswap indent<cr>]],
        opts
      )
    end,
    config = function()
      M:setup()
    end,
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    event = 'BufReadPost',
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPost',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = '30%', -- How many lines the window should span. Values <= 0 mean no limit.
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
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      {
        '<leader>rr',
        function()
          require('refactoring').select_refactor()
        end,
        mode = { 'n', 'x' },
        desc = 'refactoring_select',
      },
      {
        '<leader>rp',
        function()
          require('refactoring').debug.printf({ below = false })
        end,
        mode = { 'n' },
        desc = 'refactoring_printf_debug',
      },
      {
        '<leader>rv',
        function()
          require('refactoring').debug.print_var()
        end,
        mode = { 'n', 'x' },
        desc = 'refactoring_printf_debug',
      },
    },
    opts = {},
  },
}
