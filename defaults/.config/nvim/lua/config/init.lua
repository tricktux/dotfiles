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
local data_folders = {[[/sessions]], [[/ctags]]}
local cache_folders = {[[/backup]], [[/undo]]}
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
    if wiki ~= nil then
        vim.g.wiki_path = wiki
        -- vim.g.valid_device = 1
    end

    vim.g.browser_cmd = 'firefox.exe'

    _work_mappings(wdev_path)

    -- Find python
    local py = vim.fn.glob([[C:\Python*]], false, true)
    if vim.tbl_isempty(py) == nil then
        print('ERROR: Failed to find python')
    else
        -- Use the latest version found
        vim.g.python3_host_prog = py[#py] .. [[\python.exe]]
    end
end

local function _config_unix()
    local wiki = _find_dir(wikis)
    log.info("wiki = ", wiki)
    if wiki ~= nil then
        vim.g.wiki_path = wiki
        -- vim.g.valid_device = 1
    end

    vim.g.browser_cmd = '/usr/bin/firefox'

    local py = vim.g.std_data_path .. [[/pyvenv/bin/python]]
    if not utl.isfile(py) then
      print('ERROR: Failed to find python venv: ' .. py)
    else
      vim.g.python3_host_prog = py
    end
end

local function _init()
    log.info('--- Start Neovim Run ---')

    -- Disable unnecessary providers
    vim.g.loaded_python_provider = 0
    vim.g.loaded_ruby_provider = 0
    vim.g.loaded_perl_provider = 0
    vim.g.loaded_node_provider = 0

    map:set()  -- Set mappings

    if utl.has_unix() then
        _config_unix()
    else
        _config_win()
    end

    -- Create needed directories if they don't exist already
    for _, folder in pairs(data_folders) do
        log.trace(folder .. " = " .. vim.g.std_data_path .. folder)
        if not utl.isdir(vim.g.std_data_path .. folder) then
          vim.fn.mkdir(vim.g.std_data_path .. folder, "p")
        end
    end
    for _, folder in pairs(cache_folders) do
        log.trace(folder .. " = " .. vim.g.std_cache_path .. folder)
        if not utl.isdir(vim.g.std_cache_path .. folder) then
          vim.fn.mkdir(vim.g.std_cache_path .. folder, "p")
        end
    end
end

-- This function is called during the VimEnter event. From the 
-- plugin#AfterConfig function. This is done to ensure that variables and lua 
-- modules have been loaded for sure
local function _after_init()
    cpl.compl:set()
    cpl.diagn:set()
    lsp.set()
    plg.setup()
end

return {init = _init, after_vim_enter = _after_init}
