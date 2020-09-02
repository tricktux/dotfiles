local CompletionNvim = {}
local utils = require('utils/utils')
local log = require('utils/log')

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
    sorting = 'none',
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
        {"BufEnter", "*", [[lua require('config/completion'):on_attach()]]},
        {"CompleteDone", "*", [[if pumvisible() == 0 | pclose | endif]]}
    }
}

function CompletionNvim:on_attach()
    local ft = vim.bo.filetype
    if ft == 'c' or ft == 'cpp' then
        self._opts.trigger_character = {'.', '::', '->'}
    elseif ft == 'lua' then
        self._opts.trigger_character = {'.', ':'}
    else
        self._opts.trigger_character = {'.'}
    end
    -- TODO Add per buffer options
    -- require'diagnostic'.on_attach()
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

return CompletionNvim
