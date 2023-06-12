local vks = vim.keymap.set

local M = {}

M.debug_keys = {
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
  W = "<cmd>call TermDebugSendCommand('where')<cr>",
  t = "<cmd>call TermDebugSendCommand('bt')<cr>",
  G = "<cmd>Gdb<cr>",
  a = "<cmd>Asm<cr>",
  q = "<cmd>call TermDebugSendCommand('quit')<cr>",
}

M.debug_start = function()
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

function M:init()
  vim.g.termdebug_config = {
    ['disasm_window'] = 0,
  }
  vim.cmd.packadd("termdebug")

  local id = vim.api.nvim_create_augroup("TermDebugKeys", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "TermdebugStartPost",
    callback = function()
      require("stackmap").push("debug", "n", self.debug_keys)
      -- Jump to the source code window, as opposed to the Gdb window
      -- vim.cmd[[Source]]
      -- require("focus").focus_maximise()
    end,
    desc = "Set debugging keymaps",
    group = id,
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "TermdebugStopPost",
    callback = function()
      require("stackmap").pop("debug", "n")
      vks("n", "<plug>debug_start", self.debug_start, { desc = "start_debug" })
      -- For some reason, the above keymap is not being restored, so we'll
      require("mappings").search_motion()
    end,
    desc = "Delete debugging keymaps",
    group = id,
  })
end

return M
