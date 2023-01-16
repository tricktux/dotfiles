if vim.fn.has("win32") > 0 then
  return {}
end

return {
  {
    "knubie/vim-kitty-navigator",
    build = "cp ./*.py ~/.config/kitty/",
    init = function()
      vim.g.kitty_navigator_no_mappings = 1
    end,
    keys = {
      { "<a-h>", "<cmd>KittyNavigateLeft<cr>", desc = "kitty_left" },
      { "<a-j>", "<cmd>KittyNavigateDown<cr>", desc = "kitty_down" },
      { "<a-k>", "<cmd>KittyNavigateUp<cr>", desc = "kitty_up" },
      { "<a-l>", "<cmd>KittyNavigateRight<cr>", desc = "kitty_right" },
    },
  },
}
