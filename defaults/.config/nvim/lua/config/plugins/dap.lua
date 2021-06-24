local utl = require('utils.utils')

local M = {}

M.filetypes = {'c', 'cpp', 'rust'}

function M:set_mappings(bufnr)
  if not utl.has_unix() then return end

  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('dap.lua: which-key module not available')
    return
  end

  if not utl.is_mod_available('dap') then
    vim.api.nvim_err_writeln('dap.lua: dap module not available')
    return
  end

  if not utl.is_mod_available('dapui') then
    vim.api.nvim_err_writeln('dap.lua: dauip module not available')
    return
  end

  -- Determine if there is a config for this filetype
  local cft = vim.opt.filetype:get()
  local found = false
  for _, ft in ipairs(self.filetypes) do
    if ft == cft then
      found = true
      break
    end
  end
  if not found then
    return
  end

  local wk = require("which-key")
  local dap = require("dap")
  local opts = {prefix = '<localleader>p', buffer = bufnr}
  local breakpoints = {
    name = 'breakpoints',
    b = {dap.set_breakpoint, 'set_breakpoint'},
    l = {dap.list_breakpoints, 'list_breakpoints'},
    t = {dap.toggle_breakpoint, 'toggle_breakpoint'},
    e = {dap.set_exception_breakpoints, 'set_exception_breakpoints'}
  }
  local repl = {
    name = 'repl',
    o = {dap.repl.open, 'open'},
    t = {dap.repl.toggle, 'toggle'},
    c = {dap.repl.close, 'close'}
  }
  local v = require("dap.ui.variables")
  local vars = {
    name = 'variables',
    h = {v.hover, 'hover'},
    s = {v.scopes, 'scopes'},
    v = {v.visual_hover, 'visual_hover'},
    t = {v.toggle_multiline_display, 'toggle_multiline_display'}
  }
  local w = require('dap.ui.widgets')
  local widgets = {
    name = 'widgets',
    ['ss'] = {function() w.sidebar(w.scopes).open() end, 'sidebar_scopes'},
    ['sf'] = {function() w.sidebar(w.frames).open() end, 'sidebar_frames'},
    ['h'] = {function() w.hover() end, 'hover_expression'},
    ['fs'] = {
      function() w.centered_float(w.scopes).open() end, 'sidebar_scopes'
    },
    ['ff'] = {
      function() w.centered_float(w.frames).open() end, 'sidebar_frames'
    }
  }
  local u = require("dapui")
  local ui = {
    name = 'ui',
    o = {u.open, 'open'},
    c = {u.close, 'close'},
    t = {u.toggle, 'toggle'},
    f = {u.float_element, 'float_element'},
    e = {u.eval, 'eval'},
  }
  local mappings = {
    name = 'dap',
    c = {dap.continue, 'continue'},
    r = {dap.run, 'run'},
    b = breakpoints,
    o = {dap.step_over, 'step_over'},
    s = {dap.stop, 'stop'},
    i = {dap.step_into, 'step_into'},
    u = {dap.step_out, 'step_out'},
    p = {dap.pause, 'pause'},
    n = {dap.up, 'up_stacktrace'},
    d = {dap.down, 'down_stacktrace'},
    t = {dap.run_to_cursor, 'run_to_cursor'},
    l = repl,
    v = vars,
    w = widgets,
    g = ui,
  }

  wk.register(mappings, opts)
end

function M.setup()
  if not utl.is_mod_available('dap') then
    vim.api.nvim_err_writeln('dap module not available')
    return
  end

  if not utl.is_mod_available('dapui') then
    vim.api.nvim_err_writeln('dapui module not available')
    return
  end

  local dap = require('dap')
  dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- adjust as needed
    name = "lldb"
  }

  dap.configurations.cpp = {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/',
                            'file')
      end,
      cwd = '${workspaceFolder}',
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
      runInTerminal = false
    }
  }

  -- If you want to use this for rust and c, add something like this:
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp

  -- Close with: require("dapui").close()
  require("dapui").setup({
    icons = {expanded = "⯆", collapsed = "⯈"},
    mappings = {
      -- Use a table to apply multiple mappings
      expand = {"<CR>", "<2-LeftMouse>"},
      open = "o",
      remove = "d",
      edit = "e"
    },
    sidebar = {
      open_on_start = true,
      elements = {
        -- You can change the order of elements in the sidebar
        "scopes", "breakpoints", "stacks", "watches"
      },
      width = 40,
      position = "left" -- Can be "left" or "right"
    },
    tray = {
      open_on_start = true,
      elements = {"repl"},
      height = 10,
      position = "bottom" -- Can be "bottom" or "top"
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil -- Floats will be treated as percentage of your screen.
    }
  })
end

return M
