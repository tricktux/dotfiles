local cpl = require('config/completion')
local log = require('utils/log')
local utl = require('utils/utils')
local map = require('utils/keymap')

local function find_dir(dirs)
    vim.validate {dirs = {dirs, 't'}}
    for _, wiki in pairs(dirs) do
        local ok, err = utl.isdir(wiki)
        if ok then return vim.fn.expand(wiki) end
    end

    return nil
end

local function config_win() end

local function config_unix()
    local wikis = {
        '~/Documents/wiki', '~/External/reinaldo/resilio/wiki',
        '/mnt/samba/server/resilio/wiki'
    }
    local wiki = find_dir(wikis)
    log.info("wiki = ", wiki)
    if wiki ~= nil then vim.g.wiki_path = wiki end

    vim.g.browser_cmd = '/usr/bin/firefox'
end

local function _init()
    -- Needs to be defined before the first <Leader>/<LocalLeader> is used
    -- otherwise it goes to "\"
    vim.g.mapleader = [[\<Space>]]
    vim.g.mapleaderlocal = 'g'

    -- Mon Oct 30 2017 15:24: Patched fonts depend on this option. It also needs
    -- to be here. Otherwise Alt mappings stop working
    vim.o.encoding = 'utf-8'

    if utl.has_unix() then
        config_unix()
    else
        config_win()
    end

    -- For now still call init.vim
    vim.fn['init#vim']()
    map:set()
    cpl.compl:set()
    cpl.diagn:set()

    -- Lsp is set from plugin#AfterConfig
    -- lsp.set()
end

log.info('--- Start Neovim Run ---')
_init()
