local utils = require('utils/utils')
local log = require('utils/log')

-- TODO
-- Maybe set each server to its own function?
-- What about completion-nvim on_attach
local function lsp_set()
  if not utils.is_mod_available('nvim_lsp') then
      log.error("nvim_lsp was set, but module not found")
      return
  end

  local nvim_lsp = require'nvim_lsp'
  if vim.fn.executable('pyls') > 0 then
    log.info("setting up the pyls lsp...")
    nvim_lsp.pyls.setup {
      cmd = {"pyls"},
      root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
    }
  end

  if vim.fn.executable('lua-language-server') > 0 then
    log.info("setting up the lua-language-server lsp...")
    nvim_lsp.sumneko_lua.setup{
      cmd = {"lua-language-server"},
      root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
    }
  end

  if vim.fn.executable('clangd') > 0 then
    log.info("setting up the clangd lsp...")
    nvim_lsp.clangd.setup {
      cmd = {
        "clangd", "--all-scopes-completion=true", "--background-index=true",
        "--clang-tidy=true", "--completion-style=detailed",
        "--fallback-style=\"LLVM\"", "--pch-storage=memory",
        "--suggest-missing-includes", "--header-insertion=iwyu", "-j=12",
        "--header-insertion-decorators=false"
      },
      filetypes = {"c", "cpp"},
      root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
    }
  end
end

return {set = lsp_set}
