local utl = require('utils.utils')
local log = require('utils.log')
local vks = vim.keymap.set
local map = require('mappings')

local M = {}

local servers = {
  clangd = vim.fn.executable('clangd'),
  rust = vim.fn.executable('rust-analyzer'),
  ruff = vim.fn.executable('ruff-lsp'),
  pyright = vim.fn.executable('pyright-langserver'),
  omnisharp = vim.fn.executable('omnisharp'),
  zls = vim.fn.executable('zls'),
}

local activate = false

for _, v in pairs(servers) do
  if v then
    activate = true
    break
  end
end

if activate == false then
  return {}
end

local function do_buffer_clients_support_method(bufnr, capability)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  for _, client in pairs(clients) do
    local supports = false
    if vim.fn.has 'nvim-0.11' == 1 then
      supports = client:supports_method(capability, bufnr)
    else
      supports = client.supports_method(capability, { bufnr = bufnr })
    end
    if supports then
      return true
    end
  end
  return false
end

local function set_lsp_options(client_id, bufnr)
  if client_id == nil or bufnr == nil then
    return
  end
  vim.bo[bufnr].formatexpr = 'v:lua.vim.lsp.formatexpr'
  vim.bo[bufnr].omnifunc = ''
  local dp = client_id.server_capabilities.definitionProvider
  if dp then
    vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
  end
end

function M.set_lsp_mappings(bufnr)
  local opts = { silent = true, buffer = true }
  local prefix = '<localleader>l'
  local lprefix = '<leader>l'
  local lsp = vim.lsp
  local diag = vim.diagnostic
  local list = function()
    vim.print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end
  local workspace = {
    a = { lsp.buf.add_workspace_folder, 'add_workspace_folder' },
    r = { lsp.buf.remove_workspace_folder, 'remove_workspace_folder' },
    l = { list, 'list_folders' },
  }

  map.keymaps_set(workspace, 'n', opts, prefix .. 'w')
  map.keymaps_set(workspace, 'n', opts, lprefix .. 'w')
  local rename = vim.fn.exists(':IncRename') > 0 and ':IncRename '
    or lsp.buf.rename

  local mappings = {
    R = { rename, 'rename' },
    e = { lsp.buf.declaration, 'declaration' },
    d = { lsp.buf.definition, 'definition' },
    h = { lsp.buf.hover, 'hover' },
    i = { lsp.buf.implementation, 'implementation' },
    H = { lsp.buf.signature_help, 'signature_help' },
    D = { lsp.buf.type_definition, 'type_definition' },
    r = { lsp.buf.references, 'references' },
    S = { lsp.stop_client, 'stop_client' },
    n = { vim.diagnostic.open_float, 'show_line_diagnostics' },
    a = { vim.lsp.buf.code_action, 'code_action' },
    t = { '<cmd>LspRestart<cr>', 'lsp_restart' },
  }

  map.keymaps_set(mappings, 'n', opts, prefix)
  map.keymaps_set(mappings, 'n', opts, lprefix)

  -- Override default mappings with lsp intelligent analougous
  prefix = ']l'
  opts.desc = 'diagnostic_next'
  vks('n', prefix, diag.goto_next, opts)
  prefix = '[l'
  opts.desc = 'diagnostic_prev'
  vks('n', prefix, diag.goto_prev, opts)
  prefix = '<localleader>'
  mappings = {
    D = {
      function()
        vim.cmd([[vsplit]])
        lsp.buf.definition()
      end,
      'lsp_definition_split',
    },
    E = {
      function()
        vim.cmd([[vsplit]])
        lsp.buf.declaration()
      end,
      'lsp_declaration_split',
    },
    H = { lsp.buf.signature_help, 'lsp_signature_help' },
    R = { rename, 'lsp_rename' },
    d = { lsp.buf.definition, 'lsp_definition' },
    r = { lsp.buf.references, 'lsp_references' },
    n = { vim.diagnostic.open_float, 'show_line_diagnostics' },
    h = { lsp.buf.hover, 'lsp_hover' },
  }

  -- Set some keybinds conditional on server capabilities
  vks({ 'n', 'v' }, '<plug>format_code', function()
    lsp.buf.format({ async = true, timeout_ms = 5000 })
  end, { silent = true, buffer = true, desc = 'formatting' })

  map.keymaps_set(mappings, 'n', opts, prefix)
  require('plugin.telescope').set_lsp_mappings(bufnr)

  local hov_ok, hov = pcall(require, 'pretty_hover')
  if hov_ok then
    vks('n', '<localleader>h', hov.hover, { silent = true, buffer = true })
  end
  local trbl_ok, trbl = pcall(require, 'trouble')
  if trbl_ok then
    vks('n', '<s-u>', function()
      trbl.toggle('document_diagnostics')
    end, { silent = true, buffer = true })
  end
end

-- Abstract function that allows you to hook and set settings on a buffer that
-- has lsp server support
function M.setup_lsp_attach()
  local la = vim.api.nvim_create_augroup('lsp-attach', { clear = true })
  local lh = vim.api.nvim_create_augroup('lsp-highlight', { clear = true })
  local ld = vim.api.nvim_create_augroup('lsp-detach', { clear = true })

  -- LspDetach
  vim.api.nvim_create_autocmd({ 'LspDetach' }, {
    callback = function(au)
      vim.cmd('setlocal tagfunc< omnifunc< formatexpr<')
      vim.lsp.buf.clear_references()
      vim.api.nvim_clear_autocmds { group = lh, buffer = au.buf }
    end,
    desc = 'LSP detach from buffer',
    group = ld,
  })

  -- LspAttach
  vim.api.nvim_create_autocmd({ 'LspAttach' }, {
    callback = function(au)
      local client = vim.lsp.get_client_by_id(au.data.client_id)
      M.set_lsp_mappings(au.buf)
      set_lsp_options(client, au.buf)

      local sig_ok, sig = pcall(require, 'lsp_signature')
      if sig_ok then
        sig.on_attach()
      end

      -- folds
      if
        vim.fn.has('nvim-0.10') > 0
        and do_buffer_clients_support_method(
          au.buf,
          'textDocument/foldingRange'
        )
      then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldmethod = 'expr'
        vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
      end

      -- inlay hints
      if
        vim.fn.has('nvim-0.10') > 0
        and do_buffer_clients_support_method(au.buf, 'textDocument/inlayHint')
      then
        vim.lsp.inlay_hint.enable(true, { bufnr = au.buf })
        local toggle_inlay_hints = function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled { bufnr = au.buf }
          )
        end
        vks(
          'n',
          '<leader>ti',
          toggle_inlay_hints,
          { silent = true, buffer = true, desc = 'toggle_inlay_hints' }
        )
      end

      -- code lens
      if
        vim.fn.has('nvim-0.10') > 0
        and do_buffer_clients_support_method(au.buf, 'textDocument/codeLens')
      then
        vim.api.nvim_create_autocmd(
          { 'BufEnter', 'CursorHold', 'InsertLeave' },
          {
            callback = function(nested_au)
              vim.lsp.codelens.refresh({ bufnr = nested_au.buf })
            end,
            buffer = au.buf,
            desc = 'Refresh codelens for the current buffer',
            group = lh,
          }
        )
      end

      -- document highlight
      if
        do_buffer_clients_support_method(
          au.buf,
          'textDocument/documentHighlight'
        )
      then
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          callback = vim.lsp.buf.document_highlight,
          buffer = au.buf,
          desc = 'LSP Document Highlight',
          group = lh,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorHoldI' }, {
          callback = vim.lsp.buf.clear_references,
          buffer = au.buf,
          desc = 'LSP Document Highlight Clear',
          group = lh,
        })
      end
    end,
    desc = 'LSP attach to buffer',
    group = la,
  })
end

local function on_clangd_attach(client_id, bufnr)
  local opts =
    { silent = true, buffer = bufnr, desc = 'clangd_switch_source_header' }
  vim.keymap.set(
    'n',
    '<localleader>a',
    [[<cmd>ClangdSwitchSourceHeader<cr>]],
    opts
  )
  opts.desc = 'clangd_switch_source_header'
  vim.keymap.set(
    'n',
    '<localleader>A',
    [[<cmd>vs<cr><cmd>ClangdSwitchSourceHeader<cr>]],
    opts
  )
end

function M:config()
  self.setup_lsp_attach()
end

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      M:config()
    end,
  },
  {
    'mason-org/mason.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
  {
    'mason-org/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'neovim/nvim-lspconfig',
      'mason-org/mason.nvim',
    },
    opts = {
      ensure_installed = {},
    },
  },
  {
    'ray-x/lsp_signature.nvim',
    event = 'LspAttach',
  },
  {
    'hrsh7th/cmp-nvim-lsp',
    event = 'LspAttach',
  },
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {},
  },
  {
    'dgagn/diagflow.nvim',
    event = { 'LspAttach' },
    opts = {
      scope = 'line',
    },
  },
  {
    'folke/trouble.nvim',
    event = { 'LspAttach' },
    cmd = 'Trouble',
    keys = {
      {
        '<leader>oj',
        '<cmd>Trouble<cr>',
        desc = 'Trouble cmd',
      },
      {
        '<leader>ot',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>od',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>ob',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols sidebar (Trouble)',
      },
      {
        '<leader>os',
        '<cmd>Trouble lsp_document_symbols<cr>',
        desc = 'Symbols Quickfix (Trouble)',
      },
      {
        '<leader>ol',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>oq',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
    dependencies = vim.g.advanced_plugins > 0 and {
      'nvim-tree/nvim-web-devicons',
    } or {},
    opts = {
      cycle_results = false, -- cycle item list when reaching beginning or end of list
      auto_preview = false, -- automatically open preview when on an item
    },
  },
}
