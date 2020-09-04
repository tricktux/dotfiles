local log = require('utils/log')
local utils = require('utils/utils')
local api = vim.api

local M = {}

M._modes = {'n', 'v', 'x', 's', 'o', '!', 'i', 'l', 'c', 't', ''}

function M:_validate_mode(mode)
    vim.validate {mode = {mode, 'string'}}
    for _, m in pairs(self._modes) do if m == mode then return true end end
    return false
end

function M:_validate_map_args(lhs, rhs, opts, mode)
    log.trace("mode = ", mode)
    vim.validate {lhs = {lhs, 'string'}}
    vim.validate {rhs = {rhs, 'string'}}
    vim.validate {
        mode = {
            mode, function(a) return self:_validate_mode(a) end,
            'vim mapping mode'
        }
    }
    -- Do not modify orignal options
    log.trace("opts = ", opts)
    log.trace("lhs = ", lhs)
    log.trace("rhs = ", rhs)
    local copts = {}
    -- Make a copy of the opts table if valid. This way does'nt get modified 
    -- through the subsequent functions
    if opts ~= nil then copts = {unpack(opts)} end
    return copts
end

-- Abstraction over api functions for mappings
-- Note: That it supports buffer options, however it deletes from the opts table
-- Don't use it directely, use instead {i,c,n,etc..}{nore,map} functions
function M:_raw_map(lhs, rhs, opts, mode)
    -- Remove and check buffer option from opts
    if utils.table_removekey(opts, 'buffer') == true then
        -- Call buffer version
        log.trace("calling buffer mapping for: ", lhs)
        api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
        return
    end
    log.trace("calling global mapping for: ", lhs)
    api.nvim_set_keymap(mode, lhs, rhs, opts)
end

function M:_noremap(lhs, rhs, opts, mode)
    local copts = self:_validate_map_args(lhs, rhs, opts, mode)
    -- Always add noremap to opts
    copts.noremap = true
    self:_raw_map(lhs, rhs, copts, mode)
end

function M:_map(lhs, rhs, opts, mode)
    local copts = self:_validate_map_args(lhs, rhs, opts, mode)
    log.trace("copts = ", copts)
    self:_raw_map(lhs, rhs, copts, mode)
end

function M:_init()
    for _, mode in pairs(self._modes) do
        -- See help: map!
        if mode == '!' then
            M['mapi'] = function(lhs, rhs, opts)
                M:_noremap(lhs, rhs, opts, mode)
            end
        else
            M[mode .. 'noremap'] = function(lhs, rhs, opts)
                M:_noremap(lhs, rhs, opts, mode)
            end
            M[mode .. 'map'] = function(lhs, rhs, opts)
                M:_map(lhs, rhs, opts, mode)
            end
        end
    end
    log.debug("mapping = ", M)
end

-- Programatically setup all mode .. noremap functions. Such as {n,i,c}noremap
function M:set()
    self:_init()
end

return M
