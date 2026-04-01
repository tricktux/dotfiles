local M = {}

local max_filesize = 262144 -- 256 KB

local function should_disable(buf)
  if vim.fn.has('unix') > 0 then
    return false
  end

  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  if ok and stats and stats.size > max_filesize then
    vim.notify('[TreeSitter] Disabled (file too large)', vim.log.levels.WARN)
    vim.treesitter.stop(buf)
    return true
  end

  return false
end

local function set_textobject_mappings(ft)
  -- You can use the capture groups defined in `textobjects.scm`
  vim.keymap.set({ 'x', 'o' }, 'am', function()
    require 'nvim-treesitter-textobjects.select'.select_textobject(
      '@function.outer',
      'textobjects'
    )
  end, { buffer = true })
  vim.keymap.set({ 'x', 'o' }, 'im', function()
    require 'nvim-treesitter-textobjects.select'.select_textobject(
      '@function.inner',
      'textobjects'
    )
  end, { buffer = true })
  vim.keymap.set({ 'x', 'o' }, 'ac', function()
    require 'nvim-treesitter-textobjects.select'.select_textobject(
      '@class.outer',
      'textobjects'
    )
  end, { buffer = true })
  vim.keymap.set({ 'x', 'o' }, 'ic', function()
    require 'nvim-treesitter-textobjects.select'.select_textobject(
      '@class.inner',
      'textobjects'
    )
  end, { buffer = true })
  -- You can also use captures from other query groups like `locals.scm`
  vim.keymap.set({ 'x', 'o' }, 'as', function()
    require 'nvim-treesitter-textobjects.select'.select_textobject(
      '@local.scope',
      'locals'
    )
  end, { buffer = true })

  vim.keymap.set('n', '<leader>rSn', function()
    require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner'
  end, { buffer = true, desc = 'textobjects-swap-next-parameter' })
  vim.keymap.set('n', '<leader>rSp', function()
    require('nvim-treesitter-textobjects.swap').swap_previous '@parameter.outer'
  end, { buffer = true, desc = 'textobjects-swap-previous-parameter' })

  -- You can use the capture groups defined in `textobjects.scm`
  vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
    require('nvim-treesitter-textobjects.move').goto_next_start(
      '@function.outer',
      'textobjects'
    )
  end, { buffer = true })
  vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
    require('nvim-treesitter-textobjects.move').goto_next_start(
      '@class.outer',
      'textobjects'
    )
  end, { buffer = true })
  -- You can also pass a list to group multiple queries.
  vim.keymap.set({ 'n', 'x', 'o' }, ']o', function()
    require('nvim-treesitter-textobjects.move').goto_next_start(
      { '@loop.inner', '@loop.outer' },
      'textobjects'
    )
  end, { buffer = true })
  -- You can also use captures from other query groups like `locals.scm` or `folds.scm`
  vim.keymap.set({ 'n', 'x', 'o' }, ']s', function()
    require('nvim-treesitter-textobjects.move').goto_next_start(
      '@local.scope',
      'locals'
    )
  end, { buffer = true })

  vim.keymap.set({ 'n', 'x', 'o' }, ']z', function()
    require('nvim-treesitter-textobjects.move').goto_next_start(
      '@fold',
      'folds'
    )
  end, { buffer = true })

  vim.keymap.set({ 'n', 'x', 'o' }, '<c-j>', function()
    require('nvim-treesitter-textobjects.move').goto_next_start(
      '@function.outer',
      'textobjects'
    )
  end, { buffer = true })

  vim.keymap.set({ 'n', 'x', 'o' }, '<c-k>', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start(
      '@function.outer',
      'textobjects'
    )
  end, { buffer = true })

  vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
    require('nvim-treesitter-textobjects.move').goto_next_end(
      '@function.outer',
      'textobjects'
    )
  end, { buffer = true })

  vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
    require('nvim-treesitter-textobjects.move').goto_next_end(
      '@class.outer',
      'textobjects'
    )
  end, { buffer = true })

  vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start(
      '@function.outer',
      'textobjects'
    )
  end, { buffer = true })
  vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start(
      '@class.outer',
      'textobjects'
    )
  end, { buffer = true })

  vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end(
      '@function.outer',
      'textobjects'
    )
  end, { buffer = true })
  vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end(
      '@class.outer',
      'textobjects'
    )
  end, { buffer = true })

  -- Go to either the start or the end, whichever is closer.
  -- Use if you want more granular movements
  vim.keymap.set({ 'n', 'x', 'o' }, ']d', function()
    require('nvim-treesitter-textobjects.move').goto_next(
      '@conditional.outer',
      'textobjects'
    )
  end, { buffer = true })
  vim.keymap.set({ 'n', 'x', 'o' }, '[d', function()
    require('nvim-treesitter-textobjects.move').goto_previous(
      '@conditional.outer',
      'textobjects'
    )
  end, { buffer = true })

  local ts_repeat_move = require 'nvim-treesitter-textobjects.repeatable_move'

  -- Repeat movement with ; and ,
  -- ensure ; goes forward and , goes backward regardless of the last direction
  vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
  vim.keymap.set(
    { 'n', 'x', 'o' },
    ',',
    ts_repeat_move.repeat_last_move_previous
  )

  if ft == 'markdown' then
    vim.keymap.set('n', '<c-j>', function()
      require('vim.treesitter._headings').jump({ count = 1 })
    end, { buf = 0, silent = false, desc = 'Jump to next section' })
    vim.keymap.set('n', '<c-k>', function()
      require('vim.treesitter._headings').jump({ count = -1 })
    end, { buf = 0, silent = false, desc = 'Jump to previous section' })
  end
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

      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

      set_textobject_mappings(ft)
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
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    init = function()
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
      vim.g.no_plugin_maps = true

      -- Or, disable per filetype (add as you like)
      -- vim.g.no_python_maps = true
      -- vim.g.no_ruby_maps = true
      -- vim.g.no_rust_maps = true
      -- vim.g.no_go_maps = true
    end,
    config = function()
      -- put your config here
      -- configuration
      require('nvim-treesitter-textobjects').setup {
        select = {
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          -- You can choose the select mode (default is charwise 'v')
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * method: eg 'v' or 'o'
          -- and should return the mode ('v', 'V', or '<c-v>') or a table
          -- mapping query_strings to modes.
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            -- ['@class.outer'] = '<c-v>', -- blockwise
          },
          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding or succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap`.
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * selection_mode: eg 'v'
          -- and should return true of false
          include_surrounding_whitespace = false,
          move = {
            -- whether to set jumps in the jumplist
            set_jumps = true,
          },
        },
      }
    end,
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
