-- File:           plugin.lua
-- Description:    Used to configure different plugins
-- Author:		    Reinaldo Molina
-- Email:          me at molinamail dot com
-- Created:        Tue Sep 08 2020 22:20
-- Last Modified:  Tue Sep 08 2020 22:20
local utl = require('utils/utils')
local log = require('utils/log')

local function setup_treesitter()
    if not utl.is_mod_available('nvim-treesitter') then
        log.error('nvim-treesitter module not available')
        return
    end

    require'nvim-treesitter.configs'.setup {
        -- This line will install all of them
        -- one of "all", "language", or a list of languages
        ensure_installed = {
            "c", "cpp", "python", "lua", "java", "bash", "c_sharp", "markdown"
        },
        highlight = {
            enable = true -- false will disable the whole extension
        }
        -- disable = {"c", "rust"} -- list of language that will be disabled
    }
end

local function setup() setup_treesitter() end

return {setup = setup}
