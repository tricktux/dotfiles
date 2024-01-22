local utl = require("utils.utils")
local log = require("utils.log")
local vks = vim.keymap.set
local map = require("mappings")

local M = {}

local function set_lsp_options(client_id, bufnr)
  if client_id == nil or bufnr == nil then
    return
  end
  vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr"
  vim.bo[bufnr].omnifunc = ""
  local dp = client_id.server_capabilities.definitionProvider
  if dp then
    vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
  end
end

function M.set_lsp_mappings(bufnr)
  local opts = { silent = true, buffer = true }
  local prefix = "<localleader>l"
  local lprefix = "<leader>l"
  local lsp = vim.lsp
  local diag = vim.diagnostic
  local list = function()
    vim.print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end
  local workspace = {
    a = { lsp.buf.add_workspace_folder, "add_workspace_folder" },
    r = { lsp.buf.remove_workspace_folder, "remove_workspace_folder" },
    l = { list, "list_folders" },
  }

  map.keymaps_set(workspace, "n", opts, prefix .. "w")
  map.keymaps_set(workspace, "n", opts, lprefix .. "w")
  local rename = vim.fn.exists(":IncRename") > 0 and ":IncRename " or lsp.buf.rename

  local mappings = {
    R = { rename, "rename" },
    e = { lsp.buf.declaration, "declaration" },
    d = { lsp.buf.definition, "definition" },
    h = { lsp.buf.hover, "hover" },
    i = { lsp.buf.implementation, "implementation" },
    H = { lsp.buf.signature_help, "signature_help" },
    D = { lsp.buf.type_definition, "type_definition" },
    r = { lsp.buf.references, "references" },
    S = { lsp.stop_client, "stop_client" },
    n = { vim.diagnostic.open_float, "show_line_diagnostics" },
    a = { vim.lsp.buf.code_action, "code_action" },
    t = { "<cmd>LspRestart<cr>", "lsp_restart" }
  }

  map.keymaps_set(mappings, "n", opts, prefix)
  map.keymaps_set(mappings, "n", opts, lprefix)

  -- Override default mappings with lsp intelligent analougous
  prefix = "]l"
  opts.desc = "diagnostic_next"
  vks("n", prefix, diag.goto_next, opts)
  prefix = "[l"
  opts.desc = "diagnostic_prev"
  vks("n", prefix, diag.goto_prev, opts)
  prefix = "<localleader>"
  mappings = {
    D = {
      function()
        vim.cmd([[vsplit]])
        lsp.buf.definition()
      end,
      "lsp_definition_split",
    },
    E = {
      function()
        vim.cmd([[vsplit]])
        lsp.buf.declaration()
      end,
      "lsp_declaration_split",
    },
    H = { lsp.buf.signature_help, "lsp_signature_help" },
    R = { rename, "lsp_rename" },
    d = { lsp.buf.definition, "lsp_definition" },
    r = { lsp.buf.references, "lsp_references" },
    n = { vim.diagnostic.open_float, "show_line_diagnostics" },
    h = { lsp.buf.hover, "lsp_hover" },
  }

  -- Set some keybinds conditional on server capabilities
  mappings.f = {
    function()
      lsp.buf.format({ async = false })
    end,
    "formatting",
  }

  map.keymaps_set(mappings, "n", opts, prefix)
  require("plugins.telescope").set_lsp_mappings(bufnr)

  local hov_ok, hov = pcall(require, "pretty_hover")
  if hov_ok then
    vks("n", "<localleader>h", hov.hover, { silent = true, buffer = true })
  end
  local trbl_ok, trbl = pcall(require, "trouble")
  if trbl_ok then
    vks("n", "<s-u>", function()
      trbl.toggle("document_diagnostics")
    end, { silent = true, buffer = true })
  end
end

local lsp_init_check = function()
  return vim.b.did_on_lsp_attach == 1 and true or false
end

-- Abstract function that allows you to hook and set settings on a buffer that
-- has lsp server support
function M.on_lsp_attach(client_id, bufnr)
  if lsp_init_check() then
    return
  end

  vim.validate({ client_id = { client_id, "table" }, bufnr = { bufnr, "number" } })

  vim.b.did_on_lsp_attach = 1

  M.set_lsp_mappings(bufnr)
  set_lsp_options(client_id, bufnr)

  local sig_ok, sig = pcall(require, "lsp_signature")
  if sig_ok then
    sig.on_attach()
  end

  local id = vim.api.nvim_create_augroup("LspStuff", { clear = true })
  vim.api.nvim_create_autocmd({ "LspDetach" }, {
    callback = function(au)
      vim.b.did_on_lsp_attach = nil
      vim.cmd("setlocal tagfunc< omnifunc< formatexpr<")
    end,
    buffer = bufnr,
    desc = "Detach from buffer",
    group = id,
  })
  if vim.fn.has("nvim-0.10") > 0 and client_id.supports_method("textDocument/inlayHint") then
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      callback = function(au)
        vim.lsp.inlay_hint.enable(au.buf, true)
      end,
      buffer = bufnr,
      desc = "Highlight inlay hints",
      group = id,
    })
  end
  if client_id.supports_method("textDocument/codeLens") then
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      callback = vim.lsp.codelens.refresh,
      buffer = bufnr,
      desc = "Refresh codelens for the current buffer",
      group = id,
    })
  end
  -- Highlights references to word under the cursor
  if client_id.supports_method("textDocument/documentHighlight") then
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      callback = vim.lsp.buf.document_highlight,
      buffer = bufnr,
      desc = "LSP Document Highlight",
      group = id,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      callback = vim.lsp.buf.clear_references,
      buffer = bufnr,
      desc = "LSP Document Highlight clear",
      group = id,
    })
  end
end

local function on_clangd_attach(client_id, bufnr)
  if lsp_init_check() then
    return
  end

  local opts = { silent = true, buffer = bufnr, desc = "clangd_switch_source_header" }
  vim.keymap.set("n", "<localleader>a", [[<cmd>ClangdSwitchSourceHeader<cr>]], opts)
  opts.desc = "clangd_switch_source_header"
  vim.keymap.set("n", "<localleader>A", [[<cmd>vs<cr><cmd>ClangdSwitchSourceHeader<cr>]], opts)
  return M.on_lsp_attach(client_id, bufnr)
end

function M:config()
  local nvim_lsp = require("lspconfig")
  -- vim.lsp.log.set_level("debug")
  local cmp_lsp = require("cmp_nvim_lsp")

  local capabilities = cmp_lsp.default_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  local flags = { allow_incremental_sync = true, debounce_text_changes = 150 }

  if vim.fn.executable("lua-language-server") > 0 then
    log.info("setting up the lua lsp...")
    nvim_lsp.lua_ls.setup({
      on_attach = self.on_lsp_attach,
      flags = flags,
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = "LuaJIT",
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { "vim" },
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
  if vim.fn.executable("omnisharp") > 0 then
    log.info("setting up the omnisharp lsp...")
    nvim_lsp.omnisharp.setup({
      on_attach = self.on_lsp_attach,
      flags = flags,
      filetypes = { "cs" },
      cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
      root_dir = nvim_lsp.util.root_pattern(".vs", "*.csproj", "*.sln"),
      capabilities = capabilities,
    })
  end

  if vim.fn.executable("ruff-lsp") > 0 then
    log.info("setting up the ruff lsp...")

    nvim_lsp.ruff_lsp.setup({
      init_options = {
        settings = {
          -- Any extra CLI arguments for `ruff` go here.
          args = {},
        },
      },
    })
  elseif vim.fn.executable("pyright-langserver") > 0 then
    -- cinst nodejs-lts -y
    -- npm install -g pyright
    log.info("setting up the pyright lsp...")
    nvim_lsp.pyright.setup({
      on_attach = self.on_lsp_attach,
      flags = flags,
      capabilities = capabilities,
    })
  end

  if vim.fn.executable("remark-language-server") > 0 then
    log.info("setting up the remark-language-server lsp...")
    nvim_lsp.remark_ls.setup({})
  end

  if vim.fn.executable("bash-language-server") > 0 then
    log.info("setting up the bash-language-server lsp...")
    nvim_lsp.bashls.setup({})
  end

  if vim.fn.executable("cmake-language-server") > 0 then
    log.info("setting up the cmake-language-server lsp...")
    nvim_lsp.cmake.setup({})
  end

  if vim.fn.executable("marksman") > 0 then
    log.info("setting up the marksman lsp...")
    nvim_lsp.marksman.setup({})
  end

  if vim.fn.executable("clangd") > 0 then
    log.info("setting up the clangd lsp...")
    local cores = utl.has_win and os.getenv("NUMBER_OF_PROCESSORS") or table.concat(vim.fn.systemlist("nproc"))
    local c = vim.deepcopy(capabilities)
    c.offsetEncoding = "utf-16" -- Set the same encoding only for clangd

    local settings = {
      init_options = { clangdFileStatus = false },
      on_attach = on_clangd_attach,
      flags = flags,
      filetypes = { "c", "cpp" },
      capabilities = c,
      cmd = {
        "clangd",
        "--all-scopes-completion=true",
        "--background-index=true",
        "--clang-tidy=true",
        "--cross-file-rename=true",
        "--completion-style=detailed",
        "--fallback-style=LLVM",
        "--pch-storage=memory",
        "--header-insertion=iwyu",
        "-j=" .. cores,
        "--header-insertion-decorators=false",
      },
    }

    nvim_lsp.clangd.setup(settings)
  end

  if vim.fn.executable("rust-analyzer") > 0 then
    log.info("setting up the rust-analyzer...")
    nvim_lsp.rust_analyzer.setup({
      on_attach = self.on_lsp_attach,
      flags = flags,
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          imports = {
            granularity = {
              group = "module",
            },
            prefix = "self",
          },
          assist = {
            importGranularity = "module",
            importPrefix = "by_self",
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

  if vim.fn.executable("zig") > 0 then
    nvim_lsp.zls.setup({})
  end

  if vim.fn.executable("nil") > 0 then
    nvim_lsp.nil_ls.setup({})
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      M:config()
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
  },
  {
    "Fildo7525/pretty_hover",
    event = "LspAttach",
    opts = {},
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    event = "LspAttach",
  },
  {
    "smjonas/inc-rename.nvim",
    event = "LspAttach",
    opts = {},
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
  {
    "dgagn/diagflow.nvim",
    event = { "LspAttach" },
    opts = {
      scope = "line",
    },
  },
  {
    "folke/trouble.nvim",
    event = { "LspAttach" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      cycle_results = false, -- cycle item list when reaching beginning or end of list
    },
  },
  set_lsp_mappings = M.set_lsp_mappings,
  on_attach = M.on_lsp_attach,
}
