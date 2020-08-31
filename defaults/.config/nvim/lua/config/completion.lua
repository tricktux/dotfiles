-- local api = vim.api
--
local function set_external_sources()
    vim.cmd([[Plug 'steelsojka/completion-buffers']])

    vim.g.completion_chain_complete_list =
        {
            {complete_items = {'snippet', 'buffers'}},
            {complete_items = {'lsp'}},
            {complete_items = {'path'}},
            {mode = {'<c-n>'}}, {mode = {'<c-p>'}}
        }
end

local function lsp_enable()
    vim.cmd([[Plug 'neovim/nvim-lspconfig']])

    -- Internal variable
    vim.g.nvim_lsp_support = 1
end

local function set()
    vim.cmd([[Plug 'nvim-lua/completion-nvim']])

    vim.g.completion_enable_snippet = 'Neosnippet'
    vim.g.completion_enable_in_comment = 1
    vim.g.completion_trigger_keyword_length = 2
    -- vim.g.completion_confirm_key = [[<c-k>]]
    vim.g.completion_auto_change_source = 0
    vim.g.completion_matching_ignore_case = 1

    set_external_sources()
    lsp_enable()
end

return {set = set}
