local utl = require('utils.utils')
local map = require('utils.keymap')
local log = require('utils.log')

local function setup_fidget()
  require'fidget'.setup{
    text = {
      spinner = "dots",         -- animation shown when tasks are ongoing
      done = "✔",               -- character shown when all tasks are complete
      commenced = "Started",    -- message shown when task starts
      completed = "Completed",  -- message shown when task completes
    },
    align = {
      bottom = true,            -- align fidgets along bottom edge of buffer
      right = true,             -- align fidgets along right edge of buffer
    },
    timer = {
      spinner_rate = 125,       -- frame rate of spinner animation, in ms
      fidget_decay = 2000,      -- how long to keep around empty fidget, in ms
      task_decay = 1000,        -- how long to keep around completed task, in ms
    },
    fmt = {
      leftpad = true,           -- right-justify text in fidget box
      fidget =                  -- function to format fidget title
        function(fidget_name, spinner)
          return string.format("%s %s", spinner, fidget_name)
        end,
      task =                    -- function to format each task line
        function(task_name, message, percentage)
          return string.format(
          "%s%s [%s]",
          message,
          percentage and string.format(" (%s%%)", percentage) or "",
          task_name
          )
        end,
    },
  }
end

local function set_lsp_options(capabilities, bufnr)
  vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'
end

local function set_lsp_mappings(capabilities, bufnr)
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('lsp.lua: which-key module not available')
    return
  end

  local wk = require("which-key")
  local opts = {prefix = '<localleader>l', buffer = bufnr}
  local lsp = vim.lsp
  local list =
      '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>'
  local workspace = {
    name = 'workspace',
    a = {lsp.buf.add_workspace_folder, 'add_workspace_folder'},
    r = {lsp.buf.remove_workspace_folder, 'remove_workspace_folder'},
    l = {list, 'list_folders'}
  }
  local mappings = {
    name = 'lsp',
    r = {lsp.buf.rename, 'rename'},
    e = {lsp.buf.declaration, 'declaration'},
    d = {lsp.buf.definition, 'definition'},
    h = {lsp.buf.hover, 'hover'},
    i = {lsp.buf.implementation, 'implementation'},
    H = {lsp.buf.signature_help, 'signature_help'},
    D = {lsp.buf.type_definition, 'type_definition'},
    R = {lsp.buf.references, 'references'},
    S = {lsp.stop_all_clients, 'stop_all_clients'},
    n = {lsp.diagnostic.show_line_diagnostics, 'show_line_diagnostics'},
    l = {lsp.diagnostic.set_loclist, 'set_loclist'},
    w = workspace
  }

  -- Set some keybinds conditional on server capabilities
  if capabilities.document_formatting then
    mappings.f = {lsp.buf.formatting, 'formatting'}
  elseif capabilities.document_range_formatting then
    mappings.f = {lsp.buf.range_formatting, 'range_formatting'}
  end
  wk.register(mappings, opts)

  -- Override default mappings with lsp intelligent analougous
  opts.prefix = "]l"
  wk.register({lsp.diagnostic.goto_next, "diagnostic_next"}, opts)
  opts.prefix = "[l"
  wk.register({lsp.diagnostic.goto_prev, "diagnostic_prev"}, opts)
  opts.prefix = "<localleader>"
  mappings = {
    D = {function()
          vim.cmd[[vsplit]]
          lsp.buf.definition()
        end, 'lsp_definition_split'},
    r = {lsp.buf.rename, 'lsp_rename'},
    d = {lsp.buf.definition, 'lsp_definition'},
    u = {lsp.buf.references, 'references'},
  }

  wk.register(mappings, opts)

  if utl.is_mod_available('telescope') then
    require('config.plugins.telescope').set_lsp_mappings(bufnr)
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
  if vim.fn.exists(':NeomakeDisableBuffer') > 0 then
    if vim.bo.filetype ~= 'python' then vim.cmd('NeomakeDisableBuffer') end
  end
  -- These 2 got annoying really quickly
  -- vim.cmd(
  -- 'autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics()')
  -- vim.cmd("autocmd CursorHold <buffer> lua vim.lsp.buf.hover()")
  set_lsp_mappings(client_id.resolved_capabilities, bufnr)
  set_lsp_options(client_id.resolved_capabilities, bufnr)
  if utl.is_mod_available('dap') then
    require('config.plugins.dap'):set_mappings(bufnr)
  end
  -- require('config/completion').diagn:on_attach()

  -- Disable tagbar
  vim.b.tagbar_ignore = 1
  if utl.is_mod_available('lsp-status') then
    require('lsp-status').on_attach(client_id)
  end
  if utl.is_mod_available('lsp_signature') then
    require'lsp_signature'.on_attach()
  end
  vim.b.did_on_lsp_attach = 1
end

local function on_clangd_attach(client_id, bufnr)
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
  return on_lsp_attach(client_id, bufnr)
end

local function diagnostic_set()
  -- Taken from:
  -- https://github.com/neovim/nvim-lspconfig/issues/69
  local method = "textDocument/publishDiagnostics"
  local default_handler = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, method, result, client_id, bufnr,
                                      config)
    config = {
      virtual_text = false,
      underline = true,
      signs = true,
      update_in_insert = false,
      float = {severity_sort = true, source = "if_many"}
    }
    -- Call the default handler
    local loc = vim.fn.has('nvim-0.6') > 0 and {open = false} or
                    {open_loclist = false}
    default_handler(err, method, result, client_id, bufnr, config)
    vim.diagnostic.setloclist(loc)
    -- Do overwrite my search list
    if #vim.fn.getqflist() > 0 then return end
    local diagnostics = vim.diagnostic.get()
    local qflist = {open = false}
    for nbufnr, diagnostic in pairs(diagnostics) do
      for _, d in ipairs(diagnostic) do
        d.bufnr = nbufnr
        d.lnum = d.range.start.line + 1
        d.col = d.range.start.character + 1
        d.text = d.message
        table.insert(qflist, d)
      end
    end
    vim.diagnostic.setqflist(qflist)
  end
end

-- TODO
-- Maybe set each server to its own function?
local function lsp_set()
  if not utl.is_mod_available('lspconfig') then
    print("ERROR: lspconfig was set, but module not found")
    return
  end

  -- Notice not all configs have a `callbacks` setting
  local nvim_lsp = require('lspconfig')
  diagnostic_set()

  -- vim.lsp.set_log_level("debug")
  setup_fidget()

  local cmp_lsp = require('cmp_nvim_lsp')

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  local flags = {allow_incremental_sync = true, debounce_text_changes = 150}

  -- Unbearably slow
  if vim.fn.executable('omnisharp') > 0 then
    log.info("setting up the omnisharp lsp...")
    local pid = tostring(vim.fn.getpid())
    nvim_lsp.omnisharp.setup {
      on_attach = on_lsp_attach,
      flags = flags,
      filetypes = {"cs"},
      cmd = {"omnisharp", "--languageserver", "--hostPID", pid},
      capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp
                                                                     .protocol
                                                                     .make_client_capabilities())
    }
  end

  if vim.fn.executable('pyright-langserver') > 0 then
    log.info("setting up the pyright lsp...")
    nvim_lsp.pyright.setup {
      on_attach = on_lsp_attach,
      flags = flags,
      capabilities = cmp_lsp.update_capabilities(capabilities)
    }
  end

  if vim.fn.executable('clangd') > 0 then
    log.info("setting up the clangd lsp...")
    local cores = utl.has_win() and os.getenv("NUMBER_OF_PROCESSORS") or
                      table.concat(vim.fn.systemlist('nproc'))

    nvim_lsp.clangd.setup {
      init_options = {clangdFileStatus = false},
      on_attach = on_clangd_attach,
      flags = flags,
      filetypes = {"c", "cpp"},
      capabilities = cmp_lsp.update_capabilities(capabilities),
      cmd = {
        "clangd", "--all-scopes-completion=true", "--background-index=true",
        "--clang-tidy=true", "--completion-style=detailed",
        "--fallback-style=LLVM", "--pch-storage=memory",
        "--header-insertion=iwyu", "-j=" .. cores,
        "--header-insertion-decorators=false"
      }
    }
  end

  if vim.fn.executable('rls') > 0 then
    nvim_lsp.rls.setup {
      settings = {
        rust = {
          unstable_features = false,
          build_on_save = false,
          all_features = true,
        },
      },
    }
  end
end

return {setup = lsp_set, on_lsp_attach = on_lsp_attach}
