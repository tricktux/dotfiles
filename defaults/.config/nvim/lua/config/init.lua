-- Load module to make its functions available
-- Setup logs

local lsp = require('config/lsp')
local cpl = require('config/completion')
local log = require('utils/log')
local ut = require('utils/utils')
local map = require('utils/keymap')

local function _init()
    -- Needs to be defined before the first <Leader>/<LocalLeader> is used
    -- otherwise it goes to "\"
    vim.g.mapleader = [[\<Space>]]
    vim.g.mapleaderlocal = 'g'

    -- Mon Oct 30 2017 15:24: Patched fonts depend on this option. It also needs
    -- to be here. Otherwise Alt mappings stop working
    vim.o.encoding='utf-8'
end

log.info('--- Start Neovim Run ---')

-- For now still call init.vim
vim.fn['init#vim']()
log.info("win = " .. tostring(os.has_win()))
map:set()
cpl.compl:set()
cpl.diagn:set()
-- lsp.set()
