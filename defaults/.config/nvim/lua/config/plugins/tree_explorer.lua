local utl = require("utils/utils")
local api = vim.api

local M = {}

function M.nvimtree_config()
  -- These additional options must be set **BEFORE** calling `require'nvim-tree'` or calling setup.
  vim.g.nvim_tree_width_allow_resize = 1 -- 0 by default, will not resize the tree when opening a file

  local tree_cb = require("nvim-tree.config").nvim_tree_callback

  require("nvim-tree").setup({
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = false,
    ignore_ft_on_setup = { "startify", "dashboard" },
    open_on_tab = false,
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
      width = 30,
      side = "left",
      mappings = {
        custom_only = false,
        list = {
          -- ["<CR>"] = ":YourVimFunction()<cr>",
          -- ["u"] = ":lua require'some_module'.some_function()<cr>",
          -- default mappings
          { key = "<cr>", cb = tree_cb("edit") },
          { key = "o", cb = tree_cb("edit") },
          { key = "<c-]>", cb = tree_cb("cd") },
          { key = "<c-v>", cb = tree_cb("vsplit") },
          { key = "<c-x>", cb = tree_cb("split") },
          { key = "<c-t>", cb = tree_cb("tabnew") },
          { key = "<bs>", cb = tree_cb("close_node") },
          { key = "u", cb = tree_cb("close_node") },
          { key = "<s-cr>", cb = tree_cb("close_node") },
          { key = "<tab>", cb = tree_cb("preview") },
          { key = "I", cb = tree_cb("toggle_ignored") },
          { key = "H", cb = tree_cb("toggle_dotfiles") },
          { key = "R", cb = tree_cb("refresh") },
          { key = "a", cb = tree_cb("create") },
          { key = "d", cb = tree_cb("remove") },
          { key = "r", cb = tree_cb("rename") },
          { key = "<C-r>", cb = tree_cb("full_rename") },
          { key = "x", cb = tree_cb("cut") },
          { key = "y", cb = tree_cb("copy") },
          { key = "p", cb = tree_cb("paste") },
          { key = "[c", cb = tree_cb("prev_git_item") },
          { key = "]c", cb = tree_cb("next_git_item") },
          { key = "-", cb = tree_cb("dir_up") },
          { key = "q", cb = tree_cb("close") },
          { key = "?", cb = tree_cb("toggle_help") },
        },
      },
    },
  })

  if vim.fn.executable("ranger") > 0 then
    return
  end
  require("which-key").register({
    ["<plug>file_browser"] = { require("nvim-tree").toggle, "file-browser-neotree" },
  })
end

return M
