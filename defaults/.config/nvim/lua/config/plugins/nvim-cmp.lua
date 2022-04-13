local utl = require('utils.utils')

local M = {}

function M:setup()
  local win_sources = {{name = 'nvim_lsp'}, {name = 'buffer'}, {name = 'luasnip'}, {name = 'calc'}}
  local unix_sources = {
    {name = 'nvim_lsp'}, {name = 'buffer'}, {name = 'luasnip'}, {name = 'calc'}, {name = 'path'},
    {name = 'tags'}
  }
  local cmp = require 'cmp'
  local lspkind = require('lspkind')
  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    completion = {
      keyword_length = 2,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),
      -- Move cursor
      ['<C-f>'] = cmp.mapping.disable,
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-q>'] = cmp.mapping.close(),
      -- Used by snipets
      ['<C-j>'] = cmp.mapping.disable,
      ['<C-l>'] = cmp.mapping.disable,
      ['<C-k>'] = cmp.mapping.disable,  -- used for snippets
      -- ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      -- ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<CR>'] = cmp.mapping.disable,
    },
    sources = utl.has_unix() and unix_sources or win_sources,
    formatting = {
      format = lspkind.cmp_format {
        mode = 'text',
        maxwidth = 18,
        menu = {
          buffer = "[buf]",
          nvim_lsp = "[lsp]",
          nvim_lua = "[api]",
          path = "[path]",
          luasnip = "[snip]",
          calc = "[calc]",
        },
      },
    },
    experimental = {
      -- Let's play with this for a day or two
      ghost_text = true,
    },
    view = {
      entries = 'custom'
    }
  })
end

return M
