local utl = require("utils.utils")
local map = require("config.mappings")
local vks = vim.keymap.set

local M = {}

M.__loaded = false
M.__filetypes = {}

local function breakpoint_cond()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end

local function breakpoint_msg()
  require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end

function M:__setup_python()
  if vim.fn.executable("python") <= 0 then
    return
  end
  require("dap-python").setup("python")
  table.insert(self.__filetypes, "python")
end

function M:set_mappings(bufnr)
  if not self.__loaded then
    return
  end

  -- Determine if there is a config for this filetype
  local cft = vim.opt.filetype:get()
  local found = false
  for _, ft in ipairs(self.__filetypes) do
    if ft == cft then
      found = true
      break
    end
  end
  if not found then
    return
  end

  local dap = require("dap")
  local opts = { silent = true, buffer = bufnr }
  local prefix = "<localleader>pb"
  local breakpoints = {
    b = { dap.set_breakpoint, "set_breakpoint" },
    l = { dap.list_breakpoints, "list_breakpoints" },
    g = { breakpoint_msg, "breakpoint_with_msg" },
    c = { breakpoint_cond, "breakpoint_with_conditional" },
    t = { dap.toggle_breakpoint, "toggle_breakpoint" },
    e = { dap.set_exception_breakpoints, "set_exception_breakpoints" },
  }
  map.keymaps_set(breakpoints, "n", opts, prefix)
  local repl = {
    o = { dap.repl.open, "open" },
    t = { dap.repl.toggle, "toggle" },
    c = { dap.repl.close, "close" },
  }
  prefix = "<localleader>pl"
  map.keymaps_set(repl, "n", opts, prefix)
  local w = require("dap.ui.widgets")
  local widgets = {
    ["ss"] = {
      function()
        w.sidebar(w.scopes).open()
      end,
      "sidebar_scopes",
    },
    ["sf"] = {
      function()
        w.sidebar(w.frames).open()
      end,
      "sidebar_frames",
    },
    ["h"] = {
      function()
        w.hover()
      end,
      "hover_expression",
    },
    ["fs"] = {
      function()
        w.centered_float(w.scopes).open()
      end,
      "sidebar_scopes",
    },
    ["ff"] = {
      function()
        w.centered_float(w.frames).open()
      end,
      "sidebar_frames",
    },
  }
  prefix = "<localleader>pw"
  map.keymaps_set(widgets, "n", opts, prefix)
  local u = require("dapui")
  local ui = {
    name = "ui",
    o = { u.open, "open" },
    c = { u.close, "close" },
    t = { u.toggle, "toggle" },
    f = { u.float_element, "float_element" },
    e = { u.eval, "eval" },
  }
  prefix = "<localleader>pg"
  map.keymaps_set(ui, "n", opts, prefix)
  local mappings = {
    r = { dap.continue, "continue" },
    p = { dap.pause, "pause" },
    k = { dap.up, "up_stacktrace" },
    j = { dap.down, "down_stacktrace" },
    c = { dap.run_to_cursor, "run_to_cursor" },
    t = { dap.toggle_breakpoint, "toggle_breakpoint" },
    u = { u.toggle, "toggle_ui" },
    e = { dap.repl.toggle, "toggle_repl" },
    C = { dap.close, "close" },
    s = { dap.step_over, "step_over" },
    i = { dap.step_into, "step_into" },
    o = { dap.step_out, "step_out" },
    h = { w.hover, "hover" },
    -- Showing these guys here for reference
    ["<F2>"] = { dap.close, "close" },
    ["<F5>"] = { dap.continue, "continue" },
    ["<F8>"] = { dap.toggle_breakpoint, "toggle_breakpoint" },
    ["<F10>"] = { dap.step_over, "step_over" },
    ["<F11>"] = { dap.step_into, "step_into" },
    ["<F12>"] = { dap.step_out, "step_out" },
  }
  prefix = "<localleader>p"
  map.keymaps_set(mappings, "n", opts, prefix)

  local py = require("dap-python")
  if cft == "python" then
    mappings = {
      m = { py.test_method, "test_method" },
      c = { py.test_class, "test_class" },
      s = { py.debug_selection, "debug_selection" },
    }
    prefix = "<localleader>py"
    map.keymaps_set(mappings, "n", opts, prefix)
    opts.desc = "debug_selection"
    vks("v", "<localleader>pys", py.debug_selection, opts)
  end

  mappings = {
    ["<F2>"] = { dap.close, "close" },
    ["<F5>"] = { dap.continue, "continue" },
    ["<F8>"] = { dap.toggle_breakpoint, "toggle_breakpoint" },
    ["<F10>"] = { dap.step_over, "step_over" },
    ["<F11>"] = { dap.step_into, "step_into" },
    ["<F12>"] = { dap.step_out, "step_out" },
  }
  map.keymaps_set(mappings, "n", opts)
end

function M:__set_virt_text()
  require("nvim-dap-virtual-text").setup({
    enabled = true, -- enable this plugin (the default)
    enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    show_stop_reason = true, -- show stop reason when stopped for exceptions
    commented = false, -- prefix virtual text with comment string
    -- experimental features:
    virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
    all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
    virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
    -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
  })
end

function M:setup()
  local dap, dapui = require("dap"), require("dapui")
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  dapui.setup({
    icons = { expanded = "⯆", collapsed = "⯈" },
    mappings = {
      -- Use a table to apply multiple mappings
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
    },
    layouts = {
      {
        elements = {
          "scopes",
          "breakpoints",
          "stacks",
          "watches",
        },
        size = 40,
        position = "left",
      },
      {
        elements = {
          "repl",
          "console",
        },
        size = 10,
        position = "bottom",
      },
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil, -- Floats will be treated as percentage of your screen.
    },
  })

  self:__setup_python()

  self:__set_virt_text()

  self.__loaded = true

  if vim.fn.executable("lldb-vscode") <= 0 then
    return
  end

  dap.adapters.lldb = {
    type = "executable",
    command = utl.has_unix() and "/usr/bin/lldb-vscode" or "lldb-vscode",
    name = "lldb",
  }

  dap.configurations.cpp = {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},

      -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
      --
      --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      --
      -- Otherwise you might get the following error:
      --
      --    Error on launch: Failed to attach to the target process
      --
      -- But you should be aware of the implications:
      -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
      runInTerminal = false,
    },
  }

  -- If you want to use this for rust and c, add something like this:
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
  table.insert(self.__filetypes, "cpp")
  table.insert(self.__filetypes, "c")
  table.insert(self.__filetypes, "rust")
end

return M
