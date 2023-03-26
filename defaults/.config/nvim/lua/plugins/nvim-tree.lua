local utl = require("utils/utils")
local api = vim.api

local function nvimtree_config()
  local tree_cb = require("nvim-tree.config").nvim_tree_callback

  require("nvim-tree").setup({
    disable_netrw = true,
    hijack_netrw = true,
    hijack_cursor = false,
    update_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = { enable = true, update_cwd = true, ignore_list = {} },
    system_open = { cmd = nil, args = {} },
    filters = { dotfiles = false, custom = {} },
    renderer = {
      highlight_git = false,
      group_empty = true,
      highlight_opened_files = "all",
      add_trailing = true,
      special_files = {
        ["README.md"] = 1,
        ["Makefile"] = 1,
        ["MAKEFILE"] = 1,
      },
      icons = {
        padding = " ",
        show = { ["folder_arrow"] = false, ["folder"] = false, ["file"] = false },
      },
      indent_markers = {
        enable = true,
        icons = {
          corner = "└ ",
          edge = "│ ",
          none = "  ",
        },
      },
    },
    diagnostics = {
      enable = false,
      icons = { hint = "", info = "", warning = "", error = "" },
    },
    actions = {
      change_dir = { enable = true, global = false },
      open_file = {
        quit_on_open = true,
        resize_window = false,
        window_picker = {
          enable = false,
          chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          exclude = {
            filetype = {
              "notify",
              "packer",
              "qf",
              "diff",
              "fugitive",
              "fugitiveblame",
            },
            buftype = { "nofile", "terminal", "help" },
          },
        },
      },
    },
    view = {
      width = 50,
      side = "left",
    },
  })
end

return {
  "kyazdani42/nvim-tree.lua",
  keys = {
    {'<plug>file_browser', "<cmd>NvimTreeToggle<cr>", desc = 'file-browser-neotree'}
  },
  init = function()
    -- These additional options must be set **BEFORE** calling `require'nvim-tree'` or calling setup.
    vim.g.nvim_tree_width_allow_resize = 1 -- 0 by default, will not resize the tree when opening a file
  end,
  config = function()
    nvimtree_config()
  end,
}
