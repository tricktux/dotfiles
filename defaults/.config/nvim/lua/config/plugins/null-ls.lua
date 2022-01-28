local M = {}

function M:setup()
  local null = require("null-ls")
  null.setup({
    sources = {
      null.builtins.formatting.stylua,
      null.builtins.completion.spell
    }
  })
end

return M
