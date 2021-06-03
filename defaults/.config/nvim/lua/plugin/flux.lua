local api = vim.api

local nvim_flux = {}

nvim_flux._file_location = [[/tmp/flux]]
nvim_flux._mapping = {
  ['day'] = {
    'colorscheme ' .. vim.g.flux_day_colorscheme, 'set background=light'
  },
  ['night'] = {
    'colorscheme ' .. vim.g.flux_night_colorscheme, 'set background=dark'
  },
  ['sunrise'] = {
    'colorscheme ' .. vim.g.flux_day_colorscheme, 'set background=light'
  },
  ['sunset'] = {
    'colorscheme ' .. vim.g.flux_night_colorscheme, 'set background=dark'
  }
}

local function read_file(path)
  vim.validate {path = {path, 's'}}
  local file = io.open(path)
  if file == nil then return '' end
  local output = file:read('*all')
  file:close()
  return output
end

function nvim_flux:check()
  local period = read_file(self._file_location)
  if period == nil or period == '' then
    api.nvim_err_writeln("Failed to get daytime period from: " ..
                             self._file_location)
    return
  end

  local cmds = self._mapping[period]
  if cmds == nil then
    api.nvim_err_writeln("Failed to understand daytime period: " .. period)
    return
  end

  for _, cmd in ipairs(cmds) do vim.cmd(cmd) end
end

return nvim_flux
