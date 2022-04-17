local M = {}

--- Dependencies:
--  
M.plantuml = {
  name = "plantuml",
  filetypes = {["plantuml"] = true},
  methods = {[require("null-ls").methods.DIAGNOSTICS] = true},
  generator = {fn = function() return "I am a source!" end},
  id = 1
}
function M:setup()
  local null = require("null-ls")
  null.setup({
    sources = {null.builtins.formatting.stylua, null.builtins.completion.spell}
  })
end

return M
