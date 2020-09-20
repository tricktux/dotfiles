--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local log = {_version = "0.1.0"}

log.usecolor = true
log.outfile = vim.g.std_cache_path .. '/nvim-lua.log'
log.console = nil
log.level = "info"

local modes = {
  {name = "trace", color = "\27[34m"}, {name = "debug", color = "\27[36m"},
  {name = "info", color = "\27[32m"}, {name = "warn", color = "\27[33m"},
  {name = "error", color = "\27[31m"}, {name = "fatal", color = "\27[35m"}
}

local levels = {}
for i, v in ipairs(modes) do levels[v.name] = i end

local tostring = function(...)
  local t = {}
  for i = 1, select('#', ...) do t[#t + 1] = vim.inspect(select(i, ...)) end
  return table.concat(t, " ")
end

for i, x in ipairs(modes) do
  local nameupper = x.name:upper()
  log[x.name] = function(...)

    -- Return early if we're below the log level
    if i < levels[log.level] then return end

    local msg = tostring(...)
    local info = debug.getinfo(2, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline

    -- Output to console
    if log.console then
      print(string.format("%s[%-6s%s]%s %s: %s", log.usecolor and x.color or "",
                          nameupper, os.date("%H:%M:%S"),
                          log.usecolor and "\27[0m" or "", lineinfo, msg))
    end

    -- Output to log file
    if log.outfile then
      local fp = io.open(log.outfile, "a")
      if fp == nil then
        vim.cmd(string.format([[echomsg "Failed to open file '%s'"]],
                              log.outfile))
        return
      end
      local str = string.format("[%-6s%s] %s: %s\n", nameupper, os.date(),
                                lineinfo, msg)
      fp:write(str)
      fp:close()
    end

  end
end

return log
