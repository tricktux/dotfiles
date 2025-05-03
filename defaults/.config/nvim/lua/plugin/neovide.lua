local M = {}

M.setup = function()
  vim.o.guifont = 'Cascadia Code:h10'
  vim.g.neovide_refresh_rate = 140
  vim.g.neovide_no_idle = true
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_profiler = false
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_cursor_animation_length = 0.0
end

return M
