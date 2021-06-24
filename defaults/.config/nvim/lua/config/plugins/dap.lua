local utl = require('utils.utils')

local M = {}

-- TODO
function M.set_mappings()
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('dap.lua: which-key module not available')
    return
  end
  local wk = require("which-key")
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

  local dap = require('dap')
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
