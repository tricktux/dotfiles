local function lsp_set()
    local nvim_lsp = require 'nvim_lsp'
    nvim_lsp.pyls.setup {
        on_attach = require'completion'.on_attach,
        filetypes = "py",
        root_dir = nvim_lsp.utils.root_pattern(".git", ".svn")
        -- root_dir=get_curr_dir()
    }
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
        root_dir = nvim_lsp.utils.root_pattern(".git", ".svn")
        -- root_dir=get_curr_dir()
    }
end

return {set = lsp_set}
