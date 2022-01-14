local M = {}

function M:setup()
  local cmp = require 'cmp'
  cmp.setup({
    snippet = {},
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-u>'] = cmp.mapping.scroll_docs(4),
      ['<C-f>'] = cmp.mapping.disable,
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-q>'] = cmp.mapping.close(),
      ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-k>'] = cmp.mapping.disable,  -- used for snippets
      -- ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      -- ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
      {name = 'nvim_lsp'}, {name = 'buffer'}, {name = 'path'},
      {name = 'calc'} -- This sources slow down {name = 'treesitter'}, {name = 'tags'}
    },
    formatting = {
      format = function(entry, vim_item)
        -- fancy icons and a name of kind
        -- vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind

        -- set a name for each source
        vim_item.menu = ({
          buffer = "[buffer]",
          nvim_lsp = "[lsp]",
          nvim_lua = "[lua]",
          latex_symbols = "[latex]"
        })[entry.source.name]
        return vim_item
      end
    }
  })
end

return M
