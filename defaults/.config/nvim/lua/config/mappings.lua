local api = vim.api
local log = require("utils.log")
local fmt = string.format
local vks = vim.keymap.set
local utl = require("utils.utils")
local fs = require("utils.utils").fs
local vf = vim.fn

local M = {}

--- Abstraction over keymaps_set
-- @param keys table expects all the arguments to keymaps_set
function M:keymaps_sets(keys)
  vim.validate({ keys = { keys, "t" } })

  self.keymaps_set(keys.mappings, keys.mode, keys.opts, keys.prefix)
end

--- Abstraction over vim.keymap.set
---@param mappings (table). Example:
--  local mappings = {<lhs> = {<rhs>, <desc>, mode}}
--  The mode above is optional
--  It allows the user to overwrite the mode just for this mapping
--  The function also detects if rhs is a <plug> type mapping and adds remap
--  option for you
---@param mode table or string (optional, default = "n") same as mode in keymap
---@param opts string or function (optional default = {silent = true}) as in keymap.
--              Desc is expected in mappings
---@param prefix (string) To be prefixed to all the indices of mappings
--                Can be nil
function M.keymaps_set(mappings, mode, opts, prefix)
  vim.validate({ mappings = { mappings, "t" } })
  vim.validate({ mode = { mode, { "s", "t" }, true } })
  vim.validate({ opts = { opts, "t", true } })
  vim.validate({ prefix = { prefix, "s", true } })

  for k, v in pairs(mappings) do
    local o = vim.deepcopy(opts or { silent = true })
    o.desc = v[2] or nil
    local m = v[3] or vim.deepcopy(mode or "n")
    local lhs = prefix and prefix .. k or k

    vim.validate({ ["lhs = " .. lhs .. ", rhs = "] = { v[1], { "s", "f" } } })
    local t = type(v[1])
    if t == "string" then -- determine if rhs is a <plug> mapping
      local i, j = string.find(v[1], "^<[Pp]lug>")
      if i == 1 and j == 6 then
        o.remap = true
      end
    end
    log.trace(fmt("mapping: m = '%s', lhs = '%s', rhs = '%s', o = '%s'", vim.inspect(m), lhs, v[1], vim.inspect(o)))
    vks(m, lhs, v[1], o)
  end
end

local function refresh_buffer()
  api.nvim_exec(
    [[
  update
  nohlsearch
  diffupdate
  mode
  edit
  normal! zzze<cr>
  ]] ,
    false
  )

  local ind_ok, ind = pcall(require, "indent_blankline.commands")
  if ind_ok and ind.refresh ~= nil then
    ind.refresh(false, true)
  end

  local line_ok, line = pcall(require, "lualine")
  if line_ok and line.refresh ~= nil then
    line.refresh({kind = "all", place = { 'statusline', 'winbar', 'tabline' }})
    -- This is here just for windows.
    line.setup()
  end

  local git_ok, git = pcall(require, "gitsigns")
  if git_ok and git.refresh ~= nil then
    git.refresh()
  end
end

local function tmux_move(direction)
  local valid_dir = "phjkl"
  vim.validate({
    direction = {
      direction,
      function(d)
        return (valid_dir):find(d)
      end,
      valid_dir,
    },
  })

  local curr_win = vim.api.nvim_get_current_win()
  vf.execute("wincmd " .. direction)
  local new_win = vim.api.nvim_get_current_win()
  if new_win == curr_win then
    vf.system("tmux select-pane -" .. vf.tr(direction, valid_dir, "lLDUR"))
  end
end

local function terminal_send_line()
  local csel = utl.get_visual_selection()
  if csel == "" or csel == nil then
    return
  end
  utl.execute_in_shell(csel)
end

-- Visual mode mappings
local visual = {
  mode = "x",
}
-- Select mode mappings
local selectm = {}
selectm.mode = "s"
-- Visual and Select mode mappings
local viselect = {}
viselect.mode = "v"

-- NOTE: Please update the mappings in flux_post_{day,night,sunrise,sunset}
-- if updating these mappings below
local colors = {}
colors.prefix = "<leader>tc"
colors.mappings = {
  d = {
    function()
      require("plugin.flux"):set("day")
    end,
    "day",
  },
  n = {
    function()
      require("plugin.flux"):set("night")
    end,
    "night",
  },
  r = {
    function()
      require("plugin.flux"):set("sunrise")
    end,
    "sunrise",
  },
  s = {
    function()
      require("plugin.flux"):set("sunset")
    end,
    "sunset",
  },
}

--[[ function! s:edit_tmp_doc(type) abort
let l:sep = has('unix') ? '/' : '\'
let l:file_name = stdpath('cache') . l:sep . 'temp_' . strftime('%m%d%Y_%H%M%S')
execute 'edit ' . l:file_name . (empty(a:type) ? '' : '.' . a:type)
endfunction ]]

local edit = {}
edit.prefix = "<leader>e"
edit.edit_temporary_file = function(type)
  local s = utl.fs.sep
  local t = os.date("%y%m%d_%H%M%S")
  local f = fmt("%s%stemp_%s", vim.fn.stdpath("cache"), s, t)
  local e = type and "." .. type or ""
  vim.cmd(fmt("edit %s%s", f, e))
end
edit.mappings = {
  a = {
    function()
      fs.file.create(vim.fn.getcwd())
    end,
    "add_new_file_folder",
  },
  d = {
    function()
      fs.path.fuzzer(vim.g.dotfiles)
    end,
    "dotfiles",
  },
  h = {
    function()
      fs.path.fuzzer(os.getenv("HOME"))
    end,
    "home",
  },
  c = {
    function()
      fs.path.fuzzer(vf.getcwd())
    end,
    "current_dir",
  },
  p = {
    function()
      local p = require("config.plugins.packer").path.plugins
      fs.path.fuzzer(p)
    end,
    "lua_plugins_path",
  },
  v = {
    function()
      fs.path.fuzzer(os.getenv("VIMRUNTIME"))
    end,
    "vimruntime",
  },
  tm = {
    function() edit.edit_temporary_file("md") end,
    "edit_temporary_markdown"
  },
  tc = {
    function() edit.edit_temporary_file("cpp") end,
    "edit_temporary_cpp"
  },
  tC = {
    function() edit.edit_temporary_file("c") end,
    "edit_temporary_c"
  },
  tr = {
    function() edit.edit_temporary_file("rs") end,
    "edit_temporary_rust"
  },
  tl = {
    function() edit.edit_temporary_file("lua") end,
    "edit_temporary_lua"
  },
  tp = {
    function() edit.edit_temporary_file("py") end,
    "edit_temporary_python"
  },
  tv = {
    function() edit.edit_temporary_file("vim") end,
    "edit_temporary_vim"
  },
  tb = {
    function() edit.edit_temporary_file(utl.has_unix and "sh" or "bat") end,
    "edit_temporary_batch"
  },
  tg = {
    function()
      local o = {
        prompt = "Please enter an extention for the file: ",
        default = "lua"
      }
      local i = function(input)
        edit.edit_temporary_file(input)
      end
      vim.ui.input(o, i)
    end,
    "edit_temporary_general"
  },
  P = {
    function() vim.api.nvim_exec('edit ' .. vim.fn.getreg('+'), true) end,
    'edit_file_path_clipboard'
  }
}

local terminal = {}
terminal.mappings = {
  ["<localleader>e"] = { "<plug>terminal_send_line", "terminal_send_line" },
  ["ge"] = { "<plug>terminal_send_line_visual", "terminal_send_line_visual", "x" },
  ["<localleader>v"] = { "<plug>terminal_send_visual", "terminal_send_visual", "x" },
  ["<leader>Th"] = { "<plug>terminal_open_horizontal", "terminal_open_horizontal" },
  ["<leader>Tv"] = { "<plug>terminal_open_vertical", "terminal_open_vertical" },
  ["<a-`>"] = { "<plug>terminal_toggle", "terminal_toggle" },
  ["<plug>terminal_toggle"] = {
    function()
      utl.exec_float_term("term")
    end,
    "terminal_toggle",
  },
  ["<plug>terminal_send_line"] = {
    function()
      local csel = utl.get_visual_selection()
      if csel == "" or csel == nil then
        return
      end
      utl.execute_in_shell(csel)
    end,
    "terminal_send_line",
    { "n", "x" },
  },
}

function M:window_movement_setup()
  local opts = { silent = true, desc = "tmux_move_left" }
  if vf.has("unix") > 0 then
    if vf.exists("$TMUX") > 0 then
      vks("n", "<A-h>", function()
        tmux_move("h")
      end, opts)
      opts.desc = "tmux_move_down"
      vks("n", "<A-j>", function()
        tmux_move("j")
      end, opts)
      opts.desc = "tmux_move_up"
      vks("n", "<A-k>", function()
        tmux_move("k")
      end, opts)
      opts.desc = "tmux_move_right"
      vks("n", "<A-l>", function()
        tmux_move("l")
      end, opts)
      opts.desc = "tmux_move_prev"
      vks("n", "<A-p>", function()
        tmux_move("p")
      end, opts)
      -- elseif vim.fn.exists('$KITTY_WINDOW_ID') > 0 then
      return
    end
  end

  opts.desc = "cursor_right_win"
  vks("n", "<A-l>", "<C-w>lzz", opts)
  opts.desc = "cursor_left_win"
  vks("n", "<A-h>", "<C-w>hzz", opts)
  opts.desc = "cursor_up_win"
  vks("n", "<A-k>", "<C-w>kzz", opts)
  opts.desc = "cursor_bot_win"
  vks("n", "<A-j>", "<C-w>jzz", opts)
  opts.desc = "cursor_prev_win"
  vks("n", "<A-p>", "<C-w>pzz", opts)
end

function M:setup()
  local opts = { nowait = true, desc = "start_cmd" }
  -- Awesome hack, typing a command is used way more often than next
  vks("n", ";", ":", opts)

  opts = { silent = true, desc = "visual_end_line" }
  -- Let's make <s-v> consistent as well
  vks("n", "<s-v>", "v$h", opts)
  opts = { silent = true, desc = "visual_line" }
  vks("n", "vv", "<s-v>", opts)

  opts = { silent = true, desc = "visual_increment" }
  vks("v", "gA", "g<c-a>", opts)
  opts.desc = "visual_decrement"
  vks("v", "gX", "g<c-x>", opts)
  opts.desc = "goto_file_under_cursor"
  vks({ "v", "n" }, "]f", "gf", opts)
  opts.desc = "goto_include_under_cursor"
  vks("n", "]i", "[<c-i>", opts)
  opts.desc = "goto_include_under_cursor"
  vks("n", "[i", "[<c-i>", opts)
  opts.desc = "goto_include_under_cursor_on_right_win"
  vks("n", "]I", "<c-w>i<c-w>L", opts)
  opts.desc = "goto_include_under_cursor_on_left_win"
  vks("n", "[I", "<c-w>i<c-w>H", opts)
  opts.desc = "goto_define_under_cursor"
  vks("n", "]e", "[<c-d>", opts)
  opts.desc = "goto_define_under_cursor"
  vks("n", "[e", "[<c-d>", opts)
  opts.desc = "goto_define_under_cursor_on_right_win"
  vks("n", "]E", "<c-w>d<c-w>L", opts)
  opts.desc = "goto_define_under_cursor_on_left_win"
  vks("n", "[E", "<c-w>d<c-w>H", opts)

  vks({ "n", "x", "o" }, "t", "%")

  self:window_movement_setup()
  -- Window resizing
  opts.desc = "window_size_increase_right"
  vks("n", "<A-S-l>", "<C-w>>", opts)
  opts.desc = "window_size_increase_left"
  vks("n", "<A-S-h>", "<C-w><", opts)
  opts.desc = "window_size_increase_up"
  vks("n", "<A-S-k>", "<C-w>+", opts)
  opts.desc = "window_size_increase_bot"
  vks("n", "<A-S-j>", "<C-w>-", opts)

  opts.desc = "refresh_buffer"
  vks("n", "<c-l>", refresh_buffer, opts)

  -- Quickfix/Location list
  opts.desc = "quickfix"
  vks("n", "<s-q>", "<cmd>copen 20<cr>", opts)
  opts.desc = "quickfix"
  vks("n", "<s-u>", "<cmd>lopen 20<cr>", opts)

  opts.desc = "cwd_files"
  vks("n", "<c-p>", function()
    fs.path.fuzzer(vf.getcwd())
  end, opts)

  self:keymaps_sets(edit)
  self:keymaps_sets(colors)
  self:keymaps_sets(terminal)
end

return M
