-- Load module to make its functions available
-- Setup logs

local lsp = require('config/lsp')
local completion = require('config/completion')
local log = require 'utils/log'
local map = require('config/mapping')

log.info('--- Start Neovim Run ---')

map:set()
completion.compl:set()
completion.diagn:set()
-- lsp.set()
