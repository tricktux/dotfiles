local null = require("null-ls")
local helpers = require("null-ls.helpers")

local M = {}

--- Dependencies:
M.plantuml = {
  name = "plantuml",
  filetypes = {"plantuml"},
  method = null.methods.DIAGNOSTICS,
  generator = null.generator({
    command = "plantuml",
    args = {"$FILENAME"},
    to_stdin = true,
    from_stderr = true,
    -- choose an output format (raw, json, or line)
    format = "raw",
    check_exit_code = function(code, stderr)
      local success = code == 0

      if not success then
        -- can be noisy for things that run often (e.g. diagnostics), but can
        -- be useful for things that run on demand (e.g. formatting)
        print(stderr)
      end

      return success
    end,
    -- use helpers to parse the output from string matchers,
    -- or parse it manually with a function
    -- 'errorformat': '%EError line %l in file: %f,%Z%m',
    on_output = helpers.diagnostics.from_errorformat(
        [[%EError line %l in file: %f,%Z%m]], 'plantuml')
  }),
}

function M:setup()
  local sources = {}
  if vim.fn.executable('plantuml') > 0 then
    table.insert(sources, null.builtins.formatting.stylua)
  end

  null.setup({
    debug = false,
    diagnostics_format = "[#{c}] #{m} (#{s})",
    on_attach = require('config.lsp').on_lsp_attach,
    sources = sources
  })
  if vim.fn.executable('plantuml') > 0 then
    null.register(self.plantuml)
  end
end

return M
