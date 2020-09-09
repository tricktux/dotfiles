local lsp = require('config/lsp')
local plg = require('config/plugin')
local cpl = require('config/completion')
local log = require('utils/log')
local utl = require('utils/utils')
local map = require('utils/keymap')
local luv = vim.loop

local wikis = {
    luv.os_homedir() .. '/Documents/wiki',
    luv.os_homedir() .. '/External/reinaldo/resilio/wiki',
    '/mnt/samba/server/resilio/wiki'
}

local data_folders = {'/sessions', '/ctags', '/backup', '/swap', '/undofiles'}

local function find_dir(dirs)
    vim.validate {dirs = {dirs, 't'}}
    for _, dir in pairs(dirs) do
        log.trace("Potential dir: ", dir)
        if utl.isdir(dir) then
            log.trace("Found dir: ", dir)
            return dir
        end
    end

    log.warn("No dir found")
    return nil
end

local function config_win() end

local function config_unix()
    local wiki = find_dir(wikis)
    log.info("wiki = ", wiki)
    if wiki ~= nil then vim.g.wiki_path = wiki end

    vim.g.browser_cmd = '/usr/bin/firefox'
end

local function _init()
    log.info('--- Start Neovim Run ---')
    if utl.has_unix() then
        config_unix()
    else
        config_win()
    end

    -- For now still call init.vim
    if vim.fn['plugin#Config']() ~= 1 then
        log.error('No plugins were loaded')
    end

    -- Create needed directories if they don't exist already
    for _, folder in pairs(data_folders) do
        luv.fs_mkdir(vim.g.std_data_path .. folder, 777)
    end

    vim.fn['mappings#Set']()
    vim.fn['options#Set']()
    vim.fn['augroup#Set']()
    vim.fn['commands#Set']()
end

-- This function is called during the VimEnter event. From the 
-- plugin#AfterConfig function. This is done to ensure that variables and lua 
-- modules have been loaded for sure
local function after_init()
    map:set()
    cpl.compl:set()
    cpl.diagn:set()
    lsp.set()
    -- Treesitter really far from ready
    -- plg.setup()
end

return {init = _init, after_vim_enter = after_init}
