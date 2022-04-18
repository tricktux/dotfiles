local M = {}

--- Dependencies:
M.plantuml = {
  name = "plantuml",
  filetypes = {"plantuml"},
  methods = {[require("null-ls").methods.DIAGNOSTICS] = true},
  generator = require("null-ls").generator({
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
    on_output = require("null-ls.helpers").diagnostics.from_errorformat(
        [[%EError line %l in file: %f,%Z%m]], 'plantuml')
  }),
  id = 1
}
function M:setup()
  local null = require("null-ls")
  null.setup({
    debug = true,
    sources = {null.builtins.formatting.stylua, null.builtins.completion.spell}
  })
  null.register(self.plantuml)
end

return M
