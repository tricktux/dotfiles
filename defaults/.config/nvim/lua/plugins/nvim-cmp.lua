local utl = require('utils.utils')

local M = {}

local check_backspace = function()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

function M:setup()
  local sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'buffer', keyword_length = 3 },
    { name = 'luasnip' },
    { name = 'calc' },
    { name = 'path' },
    { name = 'orgmode' },
  }
  local cp_ok, _ = pcall(require, 'copilot_cmp')
  if cp_ok then
    table.insert(sources, 1, { name = 'copilot' })
  end

  local cmp = require('cmp')
  local luasnip = require 'luasnip'
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    completion = {
      keyword_length = 1,
    },
    mapping = cmp.mapping.preset.insert {
      -- Select the [n]ext item
      ['<c-n>'] = cmp.mapping.select_next_item(),
      -- Select the [p]revious item
      ['<c-p>'] = cmp.mapping.select_prev_item(),

      -- Scroll the documentation window [b]ack / [f]orward
      ['<c-u>'] = cmp.mapping.scroll_docs(-4),
      ['<c-d>'] = cmp.mapping.scroll_docs(4),

      -- Accept ([y]es) the completion.
      --  This will auto-import if your LSP supports it.
      --  This will expand snippets if the LSP sent a snippet.
      ['<c-y>'] = cmp.mapping.confirm { select = true },

      -- If you prefer more traditional completion keymaps,
      -- you can uncomment the following lines
      ['<cr>'] = cmp.mapping.confirm { select = true },
      ['<tab>'] = cmp.mapping.select_next_item(),
      ['<s-Tab>'] = cmp.mapping.select_prev_item(),
      ['<c-j>'] = cmp.mapping.select_next_item(),
      ['<c-k>'] = cmp.mapping.select_prev_item(),

      -- Manually trigger a completion from nvim-cmp.
      --  Generally you don't need this, because nvim-cmp will display
      --  completions whenever it has completion options available.
      ['<c-Space>'] = cmp.mapping.complete {},
      ['<c-l>'] = cmp.mapping(function()
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        end
      end, { 'i', 's' }),
      ['<c-h>'] = cmp.mapping(function()
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        end
      end, { 'i', 's' }),
      ['<c-;>'] = cmp.mapping(function()
        require('luasnip.extras.select_choice')()
      end, { 'i', 's' }),
    },
    sources = sources,
    formatting = {
      format = function(_, item)
        local icons = require('utils.utils').icons.kinds
        if icons[item.kind] then
          item.kind = icons[item.kind] .. item.kind
        end
        return item
      end,
    },
    window = {
      documentation = {
        border = 'rounded',
      },
      completion = {
        border = 'rounded',
      },
    },
    experimental = {
      -- Let's play with this for a day or two
      ghost_text = false,
    },
  })
end

local node = vim.fn.executable('node') > 0
local firenvim = vim.g.started_by_firenvim ~= nil and vim.g.started_by_firenvim > 0
local advanced = vim.g.advanced_plugins > 0
local copilot_enable = node and not firenvim and advanced
local copilot = copilot_enable and vim.g.copilot_active

return {
  {
    'hrsh7th/nvim-cmp',
    version = false, -- last release is way too old
    event = 'InsertEnter',
    config = function()
      M:setup()
    end,
  },
  {
    'hrsh7th/cmp-buffer',
    event = 'InsertEnter',
  },
  {
    'hrsh7th/cmp-path',
    event = 'InsertEnter',
  },
  {
    'hrsh7th/cmp-nvim-lua',
    event = 'InsertEnter',
  },
  {
    'hrsh7th/cmp-calc',
    event = 'InsertEnter',
  },
  {
    'saadparwaiz1/cmp_luasnip',
    event = 'InsertEnter',
  },
  copilot and {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  } or {},
  copilot and {
    'zbirenbaum/copilot-cmp',
    event = 'InsertEnter',
    dependencies = { 'zbirenbaum/copilot.lua' },
    config = function()
      require('copilot_cmp').setup()
    end,
  } or {},
}
