local utl = require('utils/utils')
local api = vim.api

local M = {}

function M.nvimtree_config()
  if not utl.is_mod_available('nvim-tree') then
    api.nvim_err_writeln("nvim-tree was set, but module not found")
    return
  end

  -- These additional options must be set **BEFORE** calling `require'nvim-tree'` or calling setup.
  vim.g.nvim_tree_quit_on_open = 1 -- 0 by default, closes the tree when you open a file
  vim.g.nvim_tree_indent_markers = 1 -- 0 by default, this option shows indent markers when folders are open
  vim.g.nvim_tree_git_hl = 0 -- 0 by default, will enable file highlight for git attributes (can be used without the icons).
  vim.g.nvim_tree_highlight_opened_files = 1  -- 0 by default, will enable folder and file icon highlight for opened files/directories.
  vim.g.nvim_tree_root_folder_modifier = ':~' -- This is the default. See :help filename-modifiers for more options
  vim.g.nvim_tree_width_allow_resize = 1 -- 0 by default, will not resize the tree when opening a file
  vim.g.nvim_tree_add_trailing = 1 -- 0 by default, append a trailing slash to folder names
  vim.g.nvim_tree_show_icons = {['git'] = 0, ['folders'] = 0, ['files'] = 0}
  vim.g.nvim_tree_group_empty = 1 -- 0 by default, compact folders that only contain a single folder into one node in the file tree
  vim.g.nvim_tree_disable_window_picker = 1 -- 0 by default, will disable the window picker.
  -- one space by default, used for rendering the space between the icon and 
  -- the filename. Use with caution, it could break rendering if you set an 
  -- empty string depending on your font.
  vim.g.nvim_tree_icon_padding = ' ' 
  vim.g.nvim_tree_special_files = { ['README.md'] = 1, ['Makefile'] = 1, ['MAKEFILE'] = 1 } -- List of filenames that gets highlighted with NvimTreeSpecialFile

  local tree_cb = require'nvim-tree.config'.nvim_tree_callback

  require'nvim-tree'.setup {
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = false,
    ignore_ft_on_setup = {'startify', 'dashboard'},
    auto_close = true,
    auto_open = true,
    tab_open = true,
    follow = true,
    open_on_tab = false,
    hijack_cursor = false,
    update_cwd = false,
    update_focused_file = {enable = true, update_cwd = true, ignore_list = {}},
    system_open = {cmd = nil, args = {}},
    filters = {
      dotfiles = false,
      custom = {}
    },
    diagnostics = {
      enable = false,
      icons = {
        hint = "",
        info = "",
        warning = "",
        error = "",
      }
    },
    update_to_buf_dir   = {
      enable = true,
      auto_open = true,
    },
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

  require('which-key').register {
    ["<plug>file_browser"] = {require('nvim-tree').toggle, "file_browser"}
  }
end

return M
