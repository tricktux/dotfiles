local utl = require('utils/utils')
local map = require('utils/keymap')
local log = require('utils/log')
local plg = require('config/plugin')

local function set_lsp_options(capabilities, bufnr)
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  if capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=Grey
      hi LspReferenceText cterm=bold ctermbg=red guibg=Grey
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=Grey
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

local function set_lsp_mappings(capabilities)
  local opts = {silent = true, buffer = true}
  local map_pref = '<localleader>l'
  local cmd_pref = '<cmd>lua vim.lsp.'
  local cmd_suff = '<cr>'
  local mappings = {
    r = 'buf.rename()',
    e = 'buf.declaration()',
    d = 'buf.definition()',
    h = 'buf.hover()',
    i = 'buf.implementation()',
    H = 'buf.signature_help()',
    D = 'buf.type_definition()',
    R = 'buf.references()',
    S = 'stop_all_clients()',
    n = 'diagnostic.show_line_diagnostics()',
    l = 'diagnostic.set_loclist()',
    ['wa'] = 'buf.add_workspace_folder()',
    ['wr'] = 'buf.remove_workspace_folder()'
  }
  for lhs, rhs in pairs(mappings) do
    log.trace("lhs = ", map_pref .. lhs, ", rhs = ",
              cmd_pref .. rhs .. cmd_suff, ", opts = ", opts)
    map.nnoremap(map_pref .. lhs, cmd_pref .. rhs .. cmd_suff, opts)
  end

  -- Workspace mappings
  map.nnoremap(map_pref .. 'wl',
               '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))' ..
                   cmd_suff, opts)

  -- Diagnostics
  map.nnoremap(']l', cmd_pref .. 'diagnostic.goto_next()' .. cmd_suff, opts)
  map.nnoremap('[l', cmd_pref .. 'diagnostic.goto_prev()' .. cmd_suff, opts)

  -- Set some keybinds conditional on server capabilities
  if capabilities.document_formatting then
    map.nnoremap(map_pref .. 'f', cmd_pref .. 'buf.formatting()' .. cmd_suff,
                 opts)
  elseif capabilities.document_range_formatting then
    map.nnoremap(map_pref .. 'f',
                 cmd_pref .. 'buf.range_formatting()' .. cmd_suff, opts)
  end

  if utl.is_mod_available('telescope') then
    cmd_pref = [[<cmd>lua require('telescope.builtin').lsp_]]
    map.nnoremap(map_pref .. 'a', cmd_pref .. 'code_actions()' .. cmd_suff, opts)
    map.nnoremap(map_pref .. 'R', cmd_pref .. 'references()' .. cmd_suff, opts)
    map.nnoremap(map_pref .. 's', cmd_pref .. 'document_symbols()' .. cmd_suff,
                 opts)
    map.nnoremap(map_pref .. 'ws',
                 cmd_pref .. 'workspace_symbols()' .. cmd_suff, opts)
  end
end

-- Abstract function that allows you to hook and set settings on a buffer that
-- has lsp server support
local function on_lsp_attach(client_id, bufnr)
  if vim.b.did_on_lsp_attach == 1 then
    -- Setup already done in this buffer
    log.debug('on_lsp_attach already setup')
    return
  end

  -- Disable neomake
  if vim.fn.exists(':NeomakeDisableBuffer') == 2 then
    vim.cmd('NeomakeDisableBuffer')
  end
  -- These 2 got annoying really quickly
  vim.cmd('autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics()')
  -- vim.cmd("autocmd CursorHold <buffer> lua vim.lsp.buf.hover()")
  set_lsp_mappings(client_id.resolved_capabilities)
  set_lsp_options(client_id.resolved_capabilities, bufnr)
  -- require('config/completion').diagn:on_attach()

  -- Disable tagbar
  vim.b.tagbar_ignore = 1
  require('lsp-status').on_attach(client_id)
  require'lsp_signature'.on_attach()
  vim.b.did_on_lsp_attach = 1
end

local function on_clangd_attach(client_id)
  if vim.b.did_on_lsp_attach == 1 then
    -- Setup already done in this buffer
    log.debug('on_lsp_attach already setup')
    return
  end

  log.debug('Setting up on_clangd_attach')
  log.debug('client_id = ', client_id)
  local opts = {silent = true, buffer = true}
  map.nnoremap('<localleader>a', [[<cmd>ClangdSwitchSourceHeader<cr>]], opts)
  map.nnoremap('<localleader>A',
               [[<cmd>vs<cr><cmd>ClangdSwitchSourceHeader<cr>]], opts)
  return on_lsp_attach(client_id)
end

local function diagnostic_set()
  -- Taken from:
  -- https://github.com/neovim/nvim-lspconfig/issues/69
  local method = "textDocument/publishDiagnostics"
  local default_handler = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, method, result, client_id, bufnr, config)
    config = {
        virtual_text = false,
        underline = true,
        signs = true,
        update_in_insert = false
    }
    -- Call the default handler
    default_handler(err, method, result, client_id, bufnr, config)
    local diagnostics = vim.lsp.diagnostic.get_all()
    local qflist = {}
    for nbufnr, diagnostic in pairs(diagnostics) do
      for _, d in ipairs(diagnostic) do
        d.bufnr = nbufnr
        d.lnum = d.range.start.line + 1
        d.col = d.range.start.character + 1
        d.text = d.message
        table.insert(qflist, d)
      end
    end
    vim.lsp.util.set_qflist(qflist)
    vim.lsp.diagnostic.set_loclist({open_loclist = false})
  end
end

-- TODO
-- Maybe set each server to its own function?
local function lsp_set()
  if not utl.is_mod_available('lspconfig') then
    print("ERROR: lspconfig was set, but module not found")
    return
  end

  if not utl.is_mod_available('lsp-status') then
    print("ERROR: lsp-status was set, but module not found")
    return
  end

  local lsp_status = require('lsp-status')
  plg.setup_lspstatus() -- Configure plugin options
  lsp_status.register_progress()
  -- Notice not all configs have a `callbacks` setting
  local nvim_lsp = require('lspconfig')
  diagnostic_set()

  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  local capabilities = lsp_status.capabilities
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- Unbearably slow
  if vim.fn.executable('omnisharp') > 0 then
    log.info("setting up the omnisharp lsp...")
    local pid = tostring(vim.fn.getpid())
    nvim_lsp.omnisharp.setup {
      on_attach = on_lsp_attach,
      cmd = {"omnisharp", "--languageserver", "--hostPID", pid},
      capabilities = capabilities
    }
  end

  if vim.fn.executable('pyls') > 0 then
    log.info("setting up the pyls lsp...")
    nvim_lsp.pyls.setup {
      on_attach = on_lsp_attach,
      cmd = {"pyls"},
      -- root_dir = nvim_lsp.util.root_pattern(".git", ".svn"),
      capabilities = capabilities,
      settings = {
        pyls = {
          plugins = {
            jedi_completion = {fuzzy = true, include_params = true},
            mccabe = {enabled = false},
            pycodestyle = {enabled = false},
            flake8 = {enabled = false},
            pydocstyle = {enabled = false},
            pyflakes = {enabled = false},
            pylint = {enabled = true},
            yapf = {enabled = false},
            pyls_mypy = {enabled = false, live_mode = false}
          }
        }
      }
    }
  end

  if vim.fn.executable('lua-language-server') > 0 then
    log.info("setting up the lua-language-server lsp...")
    nvim_lsp.sumneko_lua.setup {
      on_attach = on_lsp_attach,
      capabilities = capabilities,
      cmd = {"lua-language-server"},
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
            -- Setup your lua path
            path = vim.split(package.path, ';')
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {'vim'}
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = {
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
            }
          }
        }
      }
    }
  end

  if vim.fn.executable('clangd') > 0 then
    log.info("setting up the clangd lsp...")
    nvim_lsp.clangd.setup {
      handlers = lsp_status.extensions.clangd.setup(),
      init_options = {
        clangdFileStatus = true
      },
      on_attach = on_clangd_attach,
      capabilities = capabilities,
      cmd = {
        "clangd", "--all-scopes-completion=true", "--background-index=true",
        "--clang-tidy=true", "--completion-style=detailed",
        "--fallback-style=LLVM", "--pch-storage=memory",
        "--suggest-missing-includes", "--header-insertion=iwyu", "-j=12",
        "--header-insertion-decorators=false"
      }
      -- Default is better
      -- filetypes = {"c", "cpp"}
    }
  end
end

return {set = lsp_set}
