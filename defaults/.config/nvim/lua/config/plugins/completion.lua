local utl = require('utils/utils')
local log = require('utils/log')
local aug = require('config/augroups')
local map = require('utils/keymap')
local api = vim.api

local M = {}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then return true end

  return false
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then return t "<C-p>" end

  if vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  end
  return t "<S-Tab>"
end

local function deoplete_s_tab()
  if vim.fn.pumvisible() == 1 then
    vim.fn.feedkeys([[\<c-p>]], "n")
    return
  end

  vim.fn.feedkeys([[\<s-tab>]], "n")
end

local function deoplete_tab()
  if vim.fn.pumvisible() == 1 then
    vim.fn.feedkeys([[\<c-n>]], "n")
    return
  end

  if check_back_space() then
    vim.fn.feedkeys([[\<tab>]], "n")
    return
  end

  return vim.fn['deoplete#manual_complete']()
end

function M.deoplete()
  if vim.fn.has('python3') <= 0 then
    api.nvim_err_writeln('deoplete: Python 3 not installed')
    return
  end

  local vimp = require('vimp')
  vim.g['deoplete#enable_at_startup'] = 1

  vimp.inoremap({'expr', 'silent'}, '<c-h>',
                [[deoplete#smart_close_popup()."\<c-h>"]])
  vimp.inoremap({'expr', 'silent'}, '<bs>',
                [[deoplete#smart_close_popup()."\<C-h>"]])
  -- vimp.inoremap({'silent'}, '<tab>', deoplete_tab)
  -- vimp.inoremap({'silent'}, '<s-tab>', deoplete_s_tab)
  aug.create({
    prev_close = {
      {"CompleteDone", "*", [[if pumvisible() == 0 | pclose | endif]]}
    }
  })
end

function M.compe()

  local orgmode = utl.is_mod_available('orgmode') and true or false
  local lsp = utl.is_mod_available('lspconfig') and true or false

  require'compe'.setup {
    enabled = true,
    autocomplete = true,
    debug = true,
    min_length = 1,
    preselect = 'enable',
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,

    source = {
      path = true,
      buffer = true,
      calc = true,
      vsnip = true,
      nvim_lsp = lsp,
      nvim_lua = true,
      ultisnips = true,
      orgmode = orgmode,
      -- spell = false,
      -- tags = false,
      snippets_nvim = true
      -- treesitter = false
    }
  }

  vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()",
                          {expr = true})
  vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()",
                          {expr = true})

end

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
    comment = {},
    c = {complete_items = {'lsp', 'ts', 'snippet', 'buffer'}},
    cpp = {complete_items = {'lsp', 'ts', 'snippet', 'buffer'}},
    lua = {complete_items = {'lsp', 'ts', 'snippet', 'buffer'}},
    python = {complete_items = {'lsp', 'ts', 'snippet', 'buffer'}},
    java = {complete_items = {'lsp', 'ts', 'snippet', 'buffer'}},
    cs = {complete_items = {'lsp', 'ts', 'snippet', 'buffer'}}
  }
}

CompletionNvim._autocmds = {
  compl_nvim = {
    {"BufEnter", "*", [[lua require('config/completion').compl:on_attach()]]},
    {"CompleteDone", "*", [[if pumvisible() == 0 | pclose | endif]]}
  }
}

function CompletionNvim:on_attach()
  if vim.b.completion_enable == 1 then
    log.trace('Setup already done in this buffer')
    return
  end

  local ft = vim.bo.filetype
  if ft == 'c' or ft == 'cpp' then
    self._opts.trigger_character = {'.', '::', '->'}
    log.trace('Setting trigger characters: ', self._opts.trigger_character)
  elseif ft == 'lua' then
    self._opts.trigger_character = {'.', ':'}
  else
    self._opts.trigger_character = {'.'}
  end
  log.trace('On attach options: ', self._opts)
  require('completion').on_attach(self._opts)
end

local function smart_tab()
  if vim.fn.pumvisible() ~= 0 then
    log.trace("pum is visible, sending c-n")
    api.nvim_eval([[feedkeys("\<c-n>", "n")]])
    return
  end

  log.trace("pum is not visible, checking backspace")
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    api.nvim_eval([[feedkeys("\<tab>", "n")]])
    return
  end

  log.trace("no backspace triggering completion")
  -- TODO check if function exists
  require'completion'.triggerCompletion()
end

local function smart_s_tab()
  if vim.fn.pumvisible() ~= 0 then
    api.nvim_eval([[feedkeys("\<c-p>", "n")]])
    return
  end

  api.nvim_eval([[feedkeys("\<s-tab>", "n")]])
end

function CompletionNvim:set()
  log.info("setting up completion-nvim...")
  map.imap([[<tab>]], [[<Plug>(completion_smart_tab)]], {silent = true})
  map.imap([[<s-tab>]], [[<Plug>(completion_smart_s_tab)]], {silent = true})
  map.imap([[<c-j>]], [[<Plug>(completion_next_source)]])
  aug.create(self._autocmds)
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
  require'diagnostic'.on_attach()
end

-- return {
-- compl = CompletionNvim,
-- -- diagn = DiagnosticNvim,
-- smart_tab = smart_tab,
-- smart_s_tab = smart_s_tab
-- }
return M
