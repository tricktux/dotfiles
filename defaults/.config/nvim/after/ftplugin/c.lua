---@module c after ftplugin
---@author Reinaldo Molina
if vim.b.did_cpp_ftplugin then
  return
end

vim.b.did_cpp_ftplugin = 1
local fmt = string.format
local fn = vim.fn
local vks = vim.keymap.set
local log = require("utils.log")
local u = require("utils.utils")

local function repl()
  local comp = nil
  if fn.executable("clang++") > 0 then
    comp = "clang++"
  elseif fn.executable("g++") > 0 then
    comp = "g++"
  else
    vim.notify("[cpp.repl]: no compiler available", vim.log.levels.ERROR)
    return
  end

  local out = fn.tempname()
  local exec_out = fn.has("unix") > 0 and out or out .. ".exe"
  local filename = fn.expand("%")
  local cmd = fn.shellescape(fmt("%s %s -g -O3 -o %s && %s", comp, filename, out, exec_out))
  log.info(fmt("repl.cpp.cmd = %s", cmd))
  u.term.exec(cmd)
end

local o = { desc = "terminal_send_file" }
vks("n", "<plug>terminal_send_file", repl, o)

-- Debugging
vim.cmd.packadd("termdebug")
local debug = function()
  vim.ui.input({
    prompt = "Executable Location: ",
    completion = "file",
  }, function(input)
    if input == nil or input == "" then
      return
    end
    vim.cmd("Termdebug " .. input)
  end)
end
vks("n", "<localleader>b", debug, { desc = "start_debug" })
local debug_keys = {
  ["<localleader>br"] = "<cmd>Run<cr>",
  ["<localleader>bb"] = "<cmd>Break<cr>",
  ["<localleader>bd"] = "<cmd>Clear<cr>",
  ["<localleader>bc"] = "<cmd>Continue<cr>",
  ["<localleader>bf"] = "<cmd>Finish<cr>",
  ["<localleader>bs"] = "<cmd>Step<cr>",
  ["<localleader>bn"] = "<cmd>Over<cr>",
  ["<localleader>bu"] = "<cmd>Until<cr>",
  ["<localleader>bS"] = "<cmd>call TermDebugSendCommand('frame')<cr>",
  ["<localleader>bw"] = "<cmd>call TermDebugSendCommand('where')<cr>",
  ["<localleader>bt"] = "<cmd>call TermDebugSendCommand('bt')<cr>",
  ["<localleader>bg"] = "<cmd>Gdb<cr>",
  ["<localleader>ba"] = "<cmd>Asm<cr>",
  ["<localleader>bq"] = "<cmd>call TermDebugSendCommand('quit')<cr>",
  r = "<cmd>Run<cr>",
  b = "<cmd>Break<cr>",
  d = "<cmd>Clear<cr>",
  c = "<cmd>Continue<cr>",
  f = "<cmd>Finish<cr>",
  s = "<cmd>Step<cr>",
  n = "<cmd>Over<cr>",
  u = "<cmd>Until<cr>",
  S = "<cmd>call TermDebugSendCommand('frame')<cr>",
  w = "<cmd>call TermDebugSendCommand('where')<cr>",
  t = "<cmd>call TermDebugSendCommand('bt')<cr>",
  G = "<cmd>Gdb<cr>",
  a = "<cmd>Asm<cr>",
  q = "<cmd>call TermDebugSendCommand('quit')<cr>",
}
local id = vim.api.nvim_create_augroup("TermDebugKeys", { clear = true })
vim.api.nvim_create_autocmd("User", {
  pattern = "TermdebugStartPost",
  callback = function()
    require("stackmap").push("debug", "n", debug_keys)
    -- Jump to the source code window, as opposed to the Gdb window
    -- vim.cmd[[Source]]
  end,
  desc = "Set debugging keymaps",
  group = id,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "TermdebugStopPost",
  callback = function()
    require("stackmap").pop("debug", "n")
    vks("n", "<localleader>b", debug, { desc = "start_debug" })
  end,
  desc = "Delete debugging keymaps",
  group = id,
})
