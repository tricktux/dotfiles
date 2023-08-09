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

M.to_absolute = function(path)
  -- vim.validate(path = { path = "s" })

 if string.sub(path, 0, 1) == "/" then
    return path
  end

  if string.sub(path, 1, 2) == ":" then
    return path
  end

  return vim.fs.join(vim.fn.expand("%:p:h"), path)
end

M.find_source = function(line)
  -- vim.validate(line = { line = "s" })

  local _, si, _ = string.find(string.lower(line), M.image_type)
  if not si then
    return nil
  end

  for _, source in ipairs(M.sources) do
    for _, pattern in ipairs(source) do
      local inline_link = string.match(line, pattern[1])
      if inline_link then
        local path = string.match(inline_link, pattern[2])
        -- Check if we have a root path in a cross platform way
        path = M.to_absolute(path)
        if fs.check_sig_PNG(path) then
          return path
        else
          return nil
        end
      end
    end
  end

  return nil
end

-- TODO: return something good
return {}
