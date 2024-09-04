local utl = require('utils.utils')
local fs = require('utils.filesystem')
local log = require('utils.log')
local vks = vim.keymap.set
local map = require('mappings')

local M = {}

local servers = {
  clangd = vim.fn.executable('clangd'),
  rust = vim.fn.executable('rust-analyzer'),
  ruff = vim.fn.executable('ruff-lsp'),
  pyright = vim.fn.executable('pyright-langserver'),
}

local activate = false

for _, v in pairs(servers) do
  if v then
    activate = true
    break
  end
end

if activate == false and vim.g.advanced_plugins == 0 then
  return {}
end

M.logs_max_size = 15728640 -- 15 * 1024 * 1024 Mb

local function do_buffer_clients_support_method(bufnr, capability)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  for _, client in pairs(clients) do
    if client.supports_method(capability) then
      return true
    end
  end
  return false
end

M.cycle_logs = function()
  local filename = vim.lsp.get_log_path()
  local size = fs.file_size_native(filename)
  if not size then
    -- print("No log file found")
    return
  end
  -- Check if the size of log file is over 15MB
  if size.size < M.logs_max_size then
    -- print("Log file size:", size.size)
    return
  end

  local t = os.date('*t')
  local timestamp =
      string.format('%04d%02d%02d%02d%02d%02d', t.year, t.month, t.day, t.hour, t.min, t.sec)

  -- Rename it to ".filename.20220123120012" format
  local new_name = string.format('%s.%s', filename, timestamp)
  -- print("Renaming log file to", new_name)
  os.rename(filename, new_name)
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
  local rename = vim.fn.exists(':IncRename') > 0 and ':IncRename ' or lsp.buf.rename

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
    lsp.buf.format({ async = false })
  end, { silent = true, buffer = true, desc = 'formatting' })

  map.keymaps_set(mappings, 'n', opts, prefix)

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
  vim.api.nvim_create_autocmd({ 'LspDetach' }, {
    callback = function(au)
      vim.cmd('setlocal tagfunc< omnifunc< formatexpr<')
      vim.lsp.buf.clear_references()
      vim.api.nvim_clear_autocmds { group = lh, buffer = au.buf }
    end,
    desc = 'LSP detach from buffer',
    group = ld,
  })
  vim.api.nvim_create_autocmd({ 'LspAttach' }, {
    callback = function(au)
      local client = vim.lsp.get_client_by_id(au.data.client_id)
      M.set_lsp_mappings(au.buf)
      set_lsp_options(client, au.buf)

      local sig_ok, sig = pcall(require, 'lsp_signature')
      if sig_ok then
        sig.on_attach()
      end

      if vim.fn.has('nvim-0.10') > 0 and do_buffer_clients_support_method(au.buf, 'textDocument/inlayHint') then
        vim.lsp.inlay_hint.enable(true, { bufnr = au.buf })
      end
      if vim.fn.has('nvim-0.10') > 0 and do_buffer_clients_support_method(au.buf, 'textDocument/codeLens') then
        vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
          callback = function(nested_au)
            vim.lsp.codelens.refresh({ bufnr = nested_au.buf })
          end,
          buffer = au.buf,
          desc = 'Refresh codelens for the current buffer',
          group = lh,
        })
      end
      if do_buffer_clients_support_method(au.buf, 'textDocument/documentHighlight') then
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
  local opts = { silent = true, buffer = bufnr, desc = 'clangd_switch_source_header' }
  vim.keymap.set('n', '<localleader>a', [[<cmd>ClangdSwitchSourceHeader<cr>]], opts)
  opts.desc = 'clangd_switch_source_header'
  vim.keymap.set('n', '<localleader>A', [[<cmd>vs<cr><cmd>ClangdSwitchSourceHeader<cr>]], opts)
end

function M:config()
  local nvim_lsp = require('lspconfig')
  -- vim.lsp.log.set_level("debug")
  local cmp_lsp = require('cmp_nvim_lsp')

  local capabilities = cmp_lsp.default_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  self.setup_lsp_attach()

  local flags = { allow_incremental_sync = true, debounce_text_changes = 150 }

  if vim.fn.executable('lua-language-server') > 0 then
    log.info('setting up the lua lsp...')
    nvim_lsp.lua_ls.setup({
      flags = flags,
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' },
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          },
          hint = {
            enable = true,
          },
        },
      },
    })
  end

  -- Unbearably slow
  if vim.fn.executable('omnisharp') > 0 then
    log.info('setting up the omnisharp lsp...')
    nvim_lsp.omnisharp.setup({
      flags = flags,
      filetypes = { 'cs' },
      cmd = { 'omnisharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
      root_dir = nvim_lsp.util.root_pattern('.vs', '*.csproj', '*.sln'),
      capabilities = capabilities,
    })
  end

  if servers['ruff'] > 0 then
    log.info('setting up the ruff lsp...')

    -- https://docs.astral.sh/ruff/editors/setup/#neovim
    nvim_lsp.ruff_lsp.setup({
      init_options = {
        settings = {
          -- Any extra CLI arguments for `ruff` go here.
          args = {},
        },
      },
    })
  end
  if servers['pyright'] > 0 then
    -- cinst nodejs-lts -y
    -- npm install -g pyright
    log.info('setting up the pyright lsp...')
    nvim_lsp.pyright.setup({
      flags = flags,
      capabilities = capabilities,
      settings = {
        pyright = {
          -- Using Ruff's import organizer
          disableOrganizeImports = true,
        },
        python = {
          analysis = {
            -- Ignore all files for analysis to exclusively use Ruff for linting
            ignore = { '*' },
          },
        },
      },
    })
  end

  if vim.fn.executable('remark-language-server') > 0 then
    log.info('setting up the remark-language-server lsp...')
    nvim_lsp.remark_ls.setup({})
  end

  if vim.fn.executable('bash-language-server') > 0 then
    log.info('setting up the bash-language-server lsp...')
    nvim_lsp.bashls.setup({})
  end

  if vim.fn.executable('cmake-language-server') > 0 then
    log.info('setting up the cmake-language-server lsp...')
    nvim_lsp.cmake.setup({})
  end

  if vim.fn.executable('marksman') > 0 then
    log.info('setting up the marksman lsp...')
    nvim_lsp.marksman.setup({})
  end

  if servers['clangd'] > 0 then
    log.info('setting up the clangd lsp...')
    local cores = utl.has_win and os.getenv('NUMBER_OF_PROCESSORS')
        or table.concat(vim.fn.systemlist('nproc'))
    local c = vim.deepcopy(capabilities)
    c.offsetEncoding = 'utf-16' -- Set the same encoding only for clangd

    local settings = {
      init_options = { clangdFileStatus = false },
      on_attach = on_clangd_attach,
      flags = flags,
      filetypes = { 'c', 'cpp' },
      capabilities = c,
      cmd = {
        'clangd',
        '--all-scopes-completion=true',
        '--background-index=true',
        '--clang-tidy=true',
        '--cross-file-rename=true',
        '--completion-style=detailed',
        '--fallback-style=LLVM',
        '--pch-storage=memory',
        '--header-insertion=iwyu',
        '-j=' .. cores,
        '--header-insertion-decorators=false',
      },
    }

    nvim_lsp.clangd.setup(settings)
  end

  if servers['rust'] > 0 then
    log.info('setting up the rust-analyzer...')
    nvim_lsp.rust_analyzer.setup({
      flags = flags,
      capabilities = capabilities,
      settings = {
        ['rust-analyzer'] = {
          imports = {
            granularity = {
              group = 'module',
            },
            prefix = 'self',
          },
          assist = {
            importGranularity = 'module',
            importPrefix = 'by_self',
          },
          cargo = {
            loadOutDirsFromCheck = true,
            buildScripts = {
              enable = true,
            },
          },
          procMacro = {
            enable = true,
          },
        },
      },
    })
  end

  if vim.fn.executable('zls') > 0 then
    nvim_lsp.zls.setup({})
  end

  if vim.fn.executable('nil') > 0 then
    nvim_lsp.nil_ls.setup({})
  end
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
    dependencies = vim.g.advanced_plugins > 0 and { 'nvim-tree/nvim-web-devicons' } or {},
    opts = {
      cycle_results = false, -- cycle item list when reaching beginning or end of list
    },
  },
  cycle_logs = M.cycle_logs,
}
