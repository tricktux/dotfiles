local utl = require('utils/utils')
local api = vim.api

local M = {}

function M.nvimtree_config()
  if not utl.is_mod_available('nvim-tree') then
    api.nvim_err_writeln("nvim-tree was set, but module not found")
    return
  end

  local tree_cb = require'nvim-tree.config'.nvim_tree_callback
  require'nvim-tree'.setup {
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = false,
    ignore_ft_on_setup = {},
    auto_close = true,
    auto_open = true,
    tab_open = true,
    follow = true,
    open_on_tab = false,
    hijack_cursor = false,
    update_cwd = false,
    update_focused_file = {enable = false, update_cwd = false, ignore_list = {}},
    system_open = {cmd = nil, args = {}},
    view = {
      width = 30,
      side = 'left',
      auto_resize = false,
      mappings = {
        custom_only = false,
        list = {
          -- ["<CR>"] = ":YourVimFunction()<cr>",
          -- ["u"] = ":lua require'some_module'.some_function()<cr>",
          -- default mappings
          {key = "<cr>", cb = tree_cb("edit")},
          {key = "o", cb = tree_cb("edit")},
          {key = "<c-]>", cb = tree_cb("cd")},
          {key = "<c-v>", cb = tree_cb("vsplit")},
          {key = "<c-x>", cb = tree_cb("split")},
          {key = "<c-t>", cb = tree_cb("tabnew")},
          {key = "<bs>", cb = tree_cb("close_node")},
          {key = "u", cb = tree_cb("close_node")},
          {key = "<s-cr>", cb = tree_cb("close_node")},
          {key = "<tab>", cb = tree_cb("preview")},
          {key = "I", cb = tree_cb("toggle_ignored")},
          {key = "H", cb = tree_cb("toggle_dotfiles")},
          {key = "R", cb = tree_cb("refresh")},
          {key = "a", cb = tree_cb("create")},
          {key = "d", cb = tree_cb("remove")},
          {key = "r", cb = tree_cb("rename")},
          {key = "<C-r>", cb = tree_cb("full_rename")},
          {key = "x", cb = tree_cb("cut")}, {key = "y", cb = tree_cb("copy")},
          {key = "p", cb = tree_cb("paste")},
          {key = "[c", cb = tree_cb("prev_git_item")},
          {key = "]c", cb = tree_cb("next_git_item")},
          {key = "-", cb = tree_cb("dir_up")},
          {key = "q", cb = tree_cb("close")},
          {key = "?", cb = tree_cb("toggle_help")}
        }
      }
    }
  }
  vim.g.nvim_tree_side = 'left' -- left by default
  vim.g.nvim_tree_width = 40 -- 30 by default
  vim.g.nvim_tree_ignore = {'.git', 'node_modules', '.cache', '.svn'} -- empty by default
  vim.g.nvim_tree_auto_ignore_ft = {'startify', 'dashboard'} -- empty by default, don't auto open tree on specific filetypes.
  vim.g.nvim_tree_quit_on_open = 1 -- 0 by default, closes the tree when you open a file
  vim.g.nvim_tree_indent_markers = 1 -- 0 by default, this option shows indent markers when folders are open
  vim.g.nvim_tree_hide_dotfiles = 0 -- 0 by default, this option hides files and folders starting with a dot `.`
  vim.g.nvim_tree_git_hl = 0 -- 0 by default, will enable file highlight for git attributes (can be used without the icons).
  vim.g.nvim_tree_root_folder_modifier = ':~' -- This is the default. See :help filename-modifiers for more options
  vim.g.nvim_tree_width_allow_resize = 1 -- 0 by default, will not resize the tree when opening a file
  vim.g.nvim_tree_add_trailing = 1 -- 0 by default, append a trailing slash to folder names
  vim.g.nvim_tree_show_icons = {['git'] = 0, ['folders'] = 0, ['files'] = 0}

  require('which-key').register {
    ["<plug>file_browser"] = {require('nvim-tree').toggle, "file_browser"}
  }
end

return M
