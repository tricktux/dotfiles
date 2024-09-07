local api = vim.api
local utl = require('utils.utils')

local M = {}

M._file_location = [[/tmp/flux]]
-- Example of callback function:
--[[ local function set_colorscheme(period)
  local flavour = {
    day = "latte",
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
  vim.validate({ config = { config, 't', true } })
  self._config = vim.tbl_deep_extend('force', self._config, config)
  self:set('day') -- default
end

local _periods = { 'day', 'night', 'sunset', 'sunrise' }
local function _validate_period(period)
  return vim.tbl_contains(_periods, period)
end

function M:set(period)
  vim.validate({ period = { period, _validate_period, 'one of: ' .. vim.inspect(_periods) } })
  local cb = self._config.callback
  vim.validate({ cb = { cb, 'f' } })
  cb(period)
end

-- Function to set colorscheme based on the time of day
local function get_period_by_time()
  local hour = os.date("*t").hour  -- Get the current hour in 24-hour format

  if hour >= vim.g.flux_day_time_start and hour < vim.g.flux_day_time_end then
    return 'day'
  end
  return 'night'
end

function M:check()
  local period = utl.read_file(self._file_location)
  if period == nil or period == '' then
    -- Manually set period then based on time
    period = get_period_by_time()
  end

  self:set(period)
end

return M
