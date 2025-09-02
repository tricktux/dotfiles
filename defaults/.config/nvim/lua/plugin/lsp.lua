local fs = require('utils.filesystem')

local M = {}

M.logs_max_size = 15728640 -- 15 * 1024 * 1024 Mb

M.cycle_logs = function()
  local filename = vim.lsp.log.get_filename()
  local size = fs.file_size_native(filename)
  if size == nil then
    return
  end

  -- Check if the size of log file is over 15MB
  if size.size < M.logs_max_size then
    -- print("Log file size:", size.size)
    return
  end

  local t = os.date('*t')
  local timestamp = string.format(
    '%04d%02d%02d%02d%02d%02d',
    t.year,
    t.month,
    t.day,
    t.hour,
    t.min,
    t.sec
  )

  -- Rename it to ".filename.20220123120012" format
  local new_name = string.format('%s.%s', filename, timestamp)
  -- print("Renaming log file to", new_name)
  os.rename(filename, new_name)
end

return M
