local utils = require('utils/utils')
local log = require('utils/log')

-- Abstract function that allows you to hook and set settings on a buffer that 
-- has lsp server support
local function on_lsp_attach()
    if vim.b.did_on_lsp_attach == 1 then
        -- Setup already done in this buffer
        return
    end

    log.debug('Setting up on_lsp_attach')
    -- These 2 got annoying really quickly
    -- vim.cmd('autocmd CursorHold <buffer> lua vim.lsp.util.show_line_diagnostics()')
    -- vim.cmd("autocmd CursorHold <buffer> lua vim.lsp.buf.hover()")
    vim.fn['autocompletion#set_nvim_lsp_mappings']()
    require('config/completion').diagn:on_attach()
    vim.b.did_on_lsp_attach = 1
end

-- TODO
-- Maybe set each server to its own function?
-- What about completion-nvim on_attach
local function lsp_set()
    if not utils.is_mod_available('nvim_lsp') then
        log.error("nvim_lsp was set, but module not found")
        return
    end

    local nvim_lsp = require('nvim_lsp')
    if vim.fn.executable('pyls') > 0 then
        log.info("setting up the pyls lsp...")
        nvim_lsp.pyls.setup {
            on_attach = on_lsp_attach,
            cmd = {"pyls"},
            root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
        }
    end

    if vim.fn.executable('lua-language-server') > 0 then
        log.info("setting up the lua-language-server lsp...")
        nvim_lsp.sumneko_lua.setup {
            on_attach = on_lsp_attach,
            cmd = {"lua-language-server"},
            root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
        }
    end

    if vim.fn.executable('clangd') > 0 then
        log.info("setting up the clangd lsp...")
        nvim_lsp.clangd.setup {
            on_attach = on_lsp_attach,
            cmd = {
                "clangd", "--all-scopes-completion=true",
                "--background-index=true", "--clang-tidy=true",
                "--completion-style=detailed", "--fallback-style=\"LLVM\"",
                "--pch-storage=memory", "--suggest-missing-includes",
                "--header-insertion=iwyu", "-j=12",
                "--header-insertion-decorators=false"
            },
            filetypes = {"c", "cpp"},
            root_dir = nvim_lsp.util.root_pattern(".git", ".svn")
        }
    end
end

return {set = lsp_set}
