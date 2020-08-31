local function lsp_completion_set()
    local nvim_lsp = require 'nvim_lsp'
    nvim_lsp.pyls.setup {
        on_attach = require'completion'.on_attach,
        filetypes = {"python"},
        root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
        -- root_dir=get_curr_dir()
    }
    -- nvim_lsp.sumneko_lua.setup{on_attach=require'completion'.on_attach}
    nvim_lsp.clangd.setup {
        on_attach = require'completion'.on_attach,
        cmd = {
            "clangd", "--all-scopes-completion=true", "--background-index=true",
            "--clang-tidy=true", "--completion-style=detailed",
            "--fallback-style=\"LLVM\"", "--pch-storage=memory",
            "--suggest-missing-includes", "--header-insertion=iwyu", "-j=12",
            "--header-insertion-decorators=false"
        },
        filetypes = {"c", "cpp"},
        root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
        -- root_dir=get_curr_dir()
    }
end


local function lsp_set()
  local nvim_lsp = require 'nvim_lsp'
  nvim_lsp.pyls.setup {
    cmd = {"pyls", "--log-file", "/tmp/pyls-log.txt", "--verbose"},
    root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
  }
  nvim_lsp.sumneko_lua.setup{
    cmd = {"/usr/bin/lua-language-server"},
    root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
  }
  nvim_lsp.clangd.setup {
    cmd = {
      "/usr/bin/clangd", "--all-scopes-completion=true", "--background-index=true",
      "--clang-tidy=true", "--completion-style=detailed",
      "--fallback-style=\"LLVM\"", "--pch-storage=memory",
      "--suggest-missing-includes", "--header-insertion=iwyu", "-j=12",
      "--header-insertion-decorators=false"
    },
    filetypes = {"c", "cpp"},
    root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
  }
end

return {set = lsp_set}
