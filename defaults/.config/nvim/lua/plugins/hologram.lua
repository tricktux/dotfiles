local M = {}
local utl = require('utils.utils')
local fs = require('utils.filesystem')

if vim.g.advanced_plugins == 0 then
  return {}
end

M.holograms = {}

M.search_for_first_visible_source = function()
  local lines = utl.get_visible_lines(0)
  for _, line in ipairs(lines.visible_lines) do
    if line ~= nil then
      local source = M.links.find_source(line)
      if source ~= nil then
        return source
      end
    end
  end

  return nil
end

M.open_first_visible_image = function()
  local img = M.search_for_first_visible_source()
  if img == nil then
    vim.print('No sources found')
    return
  end

  utl.term.open_uri(img)
end

M.toggle_hologram_image_in_line = function(line)
  vim.validate({ line = { line, 's', false } })
  local hol_ok, hol = pcall(require, 'hologram')
  if not hol_ok then
    vim.api.nvim_err_writeln('hologram not installed')
    return
  end

  local s = utl.links.find_source(line)
  if s == nil then
    vim.print('No sources found')
    return
  end
  local img = fs.is_path(s)
  if img == nil then
    vim.print('File: ' .. s .. ' not found')
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local Image = require('hologram.image')
  local image = Image:new(img, {}, false)
  image:display(vim.fn.line('w0') + 1, 0, buf, {})
  table.insert(M.holograms, image)

  -- Setup autocmd to clean up hologram images
  vim.api.nvim_create_autocmd({ 'BufWinLeave', 'CursorMoved' }, {
    callback = function(au)
      for _, i in pairs(M.holograms) do
        i:delete(buf, { free = true })
      end
      M.holograms = {}
    end,
    buffer = buf,
    once = true,
  })
end

return {
  'giusgad/hologram.nvim',
  keys = {
    {
      '<plug>toggle_hologram_images',
      function()
        local line = vim.fn.getline('.')
        M.toggle_hologram_image_in_line(line)
      end,
      desc = 'toggle_hologram_images',
    },
  },
  opts = {
    auto_display = false,
  },
}
