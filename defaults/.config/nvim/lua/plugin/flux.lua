local api = vim.api
local utl = require("utils.utils")

local M = {}

M._file_location = [[/tmp/flux]]
-- Example of callback function:
--[[ local function set_colorscheme(period)
  local flavour = {
    day = "latter",
    night = "mocha",
    sunrise = "frappe",
    sunset = "macchiato",
  }
  vim.g.catppuccin_flavour = flavour[period]
  vim.cmd("colorscheme catppuccin")
end ]]
M._config = {
  ['callback'] = nil,
}

function M:setup(config)
  vim.validate({ config = { config, "t", true } })
  self._config = vim.tbl_deep_extend("force", self._config, config)
end

function M:set(period)
  vim.validate { period = { period, 's' } }
  local cb = self._config.callback
  vim.validate { cb = { cb, 'f' } }
  cb(period)
end

function M:check()
  local period = utl.read_file(self._file_location)
  if period == nil or period == '' then
    api.nvim_err_writeln("Failed to get daytime period from: " ..
      self._file_location)
    return
  end

  self:set(period)
end

return M
