local lsp = require('config/lsp')
local plg = require('config/plugin')
local cpl = require('config/completion')
local log = require('utils/log')
local utl = require('utils/utils')
local map = require('utils/keymap')
local luv = vim.loop

local home_dir = luv.os_homedir()
local wikis = {
    home_dir .. '/Documents/wiki',
    home_dir .. '/External/reinaldo/resilio/wiki',
    '/mnt/samba/server/resilio/wiki'
}
local wikis_win = {
    [[D:\Seafile\KnowledgeIsPower\wiki]],
    [[D:\wiki]],
    [[D:\Reinaldo\Documents\src\resilio\wiki]],
}
local data_folders = {'/sessions', '/ctags'}
local cache_folders = {'/backup', '/swap', '/undofiles'}
local wdev_path = [[D:/wings-dev]]
local work_repos = {
    ['1'] = [[/src/OneWings]],
    ['2'] = [[/src/OneWings2]],
    ['c'] = [[/config]],
    ['s'] = [[/src]],
}

local function _work_mappings(work_dir)
    if not utl.isdir(work_dir) then
        log.info("Work directory does not exist, must be home pc: ", work_dir)
        return
    end
    log.info("Work directory: ", work_dir)
    local map_pref = '<leader>ew'
    local cmd_pref = '<cmd>lua require("utils.utils").file_fuzzer([['
    local cmd_suff = ']])<cr>'
    local opts = { silent = true }
    for lhs, rhs in pairs(work_repos) do
        log.trace("lhs = ", map_pref .. lhs, ", rhs = ",
            cmd_pref .. work_dir .. rhs .. cmd_suff, ", opts = ", opts)
        map.nnoremap(map_pref .. lhs,
            cmd_pref .. work_dir .. rhs .. cmd_suff, opts)
    end
end

local function _find_dir(dirs)
    vim.validate {dirs = {dirs, 't'}}
    for _, dir in pairs(dirs) do
        log.trace("Potential dir: ", dir)
        if utl.isdir(dir) then
            log.trace("Found dir: ", dir)
            return dir
        end
    end

    log.trace("No dir found")
    return nil
end

local function _config_win()
    local wiki = _find_dir(wikis_win)
    log.info("wiki = ", wiki)
    if wiki ~= nil then vim.g.wiki_path = wiki end

    vim.g.browser_cmd = 'firefox.exe'

    _work_mappings(wdev_path)
end

local function _config_unix()
    local wiki = _find_dir(wikis)
    log.info("wiki = ", wiki)
    if wiki ~= nil then vim.g.wiki_path = wiki end

    vim.g.browser_cmd = '/usr/bin/firefox'
end

local function _init()
    log.info('--- Start Neovim Run ---')

    map:set()  -- Set mappings

    if utl.has_unix() then
        _config_unix()
    else
        _config_win()
    end

    if vim.fn['plugin#Config']() ~= 1 then
        log.error('No plugins were loaded')
    end

    -- Create needed directories if they don't exist already
    for _, folder in pairs(data_folders) do
        luv.fs_mkdir(vim.g.std_data_path .. folder, 777)
    end
    for _, folder in pairs(cache_folders) do
        luv.fs_mkdir(vim.g.std_cache_path .. folder, 777)
    end

    vim.fn['mappings#Set']()
    vim.fn['options#Set']()
    vim.fn['augroup#Set']()
    vim.fn['commands#Set']()
end

-- This function is called during the VimEnter event. From the 
-- plugin#AfterConfig function. This is done to ensure that variables and lua 
-- modules have been loaded for sure
local function _after_init()
    cpl.compl:set()
    cpl.diagn:set()
    lsp.set()
    -- Treesitter really far from ready
    -- plg.setup()
end

return {init = _init, after_vim_enter = _after_init}
