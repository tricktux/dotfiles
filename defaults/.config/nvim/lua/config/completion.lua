local utils = require('utils/utils')
local log = require('utils/log')

local CompletionNvim = {}
-- undocumented options:
--  docked_maximum_size
--  docked_minimum_size
--  enable_focusable_hover
CompletionNvim._opts = {
    enable_snippet = 'Neosnippet',
    enable_in_comment = 1,
    trigger_keyword_length = 2,
    auto_change_source = 0,
    matching_ignore_case = 0,
    enable_auto_paren = 0,
    docked_hover = 1,
    matching_strategy_list = {'exact', 'fuzzy'},
    sorting = 'none',
    trigger_character = {'.'},
    chain_complete_list = {
        default = {
            {complete_items = {'lsp', 'buffers', 'snippet'}},
            {complete_items = {'path'}, triggered_only = {'/'}}
        },
        string = {{complete_items = {'path'}, triggered_only = {'/'}}},
        comment = {}
    }
}

CompletionNvim._autocmds = {
    compl_nvim = {
        {
            "BufEnter", "*",
            [[lua require('config/completion').compl:on_attach()]]
        }, {"CompleteDone", "*", [[if pumvisible() == 0 | pclose | endif]]}
    }
}

function CompletionNvim:on_attach()
    if vim.b.completion_enable == 1 then
        -- Setup already done in this buffer
        return
    end

    local ft = vim.bo.filetype
    if ft == 'c' or ft == 'cpp' then
        self._opts.trigger_character = {'.', '::', '->'}
    elseif ft == 'lua' then
        self._opts.trigger_character = {'.', ':'}
    else
        self._opts.trigger_character = {'.'}
    end
    require('completion').on_attach(self._opts)
end

function CompletionNvim:set()
    if not utils.is_mod_available('completion') then
        log.error("completion-nvim was set, but module not found")
        return
    end

    log.info("setting up completion-nvim...")
    utils.create_augroups(self._autocmds)
end

local DiagnosticNvim = {}

-- Set initial settings for function
function DiagnosticNvim:set()
    vim.g.diagnostic_enable_virtual_text = 1
    vim.g.diagnostic_insert_delay = 0
    vim.g.diagnostic_auto_popup_while_jump = 1
end

-- Returns hook for nvim_lsp on_attach
--  If diagnostic-nvim plugin not found returns nil
--  Otherwise returns the diagnostic-nvim on_attach function
function DiagnosticNvim:on_attach()
    if not utils.is_mod_available('diagnostic') then
        log.error("diagnostic-nvim was set, but module not found")
        return
    end

    require'diagnostic'.on_attach()
end

return {compl = CompletionNvim, diagn = DiagnosticNvim}
