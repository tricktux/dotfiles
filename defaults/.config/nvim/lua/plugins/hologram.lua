local M = {}

M.sources = {
  -- First table is find image, second table is extract filename from match
  md = {
    { "!%[.-%]%(.-%)", "%((.+)%)" },
    { "!%[%[.-%]%]", "!%[%[(.-)%]%]" },
  },
  org = {
    {"%[%[.-%]%]", "%[%[(.-)%]%]"}
  }
}

M.image_type = "png"

M.find_source = function(line)
  vim.validate{ line = { line = "s" } }

  local plok, pl = pcall(require, "plenary.path")
  if not plok then
    vim.api.nvim_err_writeln("Failed to load plenary.path")
    return
  end

  local hlok, fs = pcall(require, "hologram.fs")
  if not hlok then
    vim.api.nvim_err_writeln("Failed to load hologram.fs")
    return
  end

  local _, si, _ = string.find(string.lower(line), M.image_type)
  if not si then
    return nil
  end

  for _, source in pairs(M.sources) do
    for _, pattern in pairs(source) do
      local inline_link = string.match(line, pattern[1])
      if inline_link then
        local path = pl:new(string.match(inline_link, pattern[2]))
        -- Check if we have a root path in a cross platform way
        if path:exists() and fs.check_sig_PNG(path:absolute()) then
          return path:absolute()
        end
      end
    end
  end

  return nil
end

M.find_source_in_buffer = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local source = nil
  for _, line in ipairs(lines) do
    source = M.find_source(line)
    if source then
      return source
    end
  end
  return nil
end

-- TODO: return something good
return {}
