local log = require("utils.log")
local map = require("config.mappings")
local null = require("null-ls")
local helpers = require("null-ls.helpers")

local M = {}

local function get_sources_for_filetype(ft)
  local srcs = null.get_sources()
  local ret = {}
  for _, v in pairs(srcs) do
    if v.filetypes[ft] == true then
      table.insert(ret, v.name)
    end
  end

  return ret
end

M.maps = {}
M.maps.mode = "n"
M.maps.prefix = "<leader>tn"
M.maps.opts = { silent = true }
M.maps.mappings = {
  d = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .."'", vim.log.levels.WARN)
        return
      end
      vim.ui.select(srcs, {
        prompt = "Select source to disable:",
        format_item = nil,
      }, function(choice)
        null.disable(choice)
      end)
    end,
    "disable_source",
  },
  e = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .."'", vim.log.levels.WARN)
        return
      end
      vim.ui.select(srcs, {
        prompt = "Select source to enable:",
        format_item = nil,
      }, function(choice)
        null.enable(choice)
      end)
    end,
    "enable_source",
  },
  s = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .."'", vim.log.levels.WARN)
        return
      end
      vim.ui.select(srcs, {
        prompt = "Select source to toggle:",
        format_item = nil,
      }, function(choice)
        null.toggle(choice)
      end)
    end,
    "toggle_source",
  },
  E = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .."'", vim.log.levels.WARN)
        return
      end
      for _, v in pairs(srcs) do
        null.enable(v)
      end
    end,
    "disable_all",
  },
  D = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .."'", vim.log.levels.WARN)
        return
      end
      for _, v in pairs(srcs) do
        null.disable(v)
      end
    end,
    "disable_all",
  },
  v = {
    function()
      vim.b.null_enable_vale = 1
      null.enable("vale")
    end,
    "vale_enable",
  },
  V = {
    function()
      vim.b.null_enable_vale = 0
      null.disable("vale")
    end,
    "vale_disable",
  },
}

--- Dependencies:
M.plantuml = {
  name = "plantuml",
  filetypes = { "plantuml" },
  method = null.methods.DIAGNOSTICS,
  generator = null.generator({
    command = "plantuml",
    args = { "$FILENAME" },
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
    on_output = helpers.diagnostics.from_errorformat([[%EError line %l in file: %f,%Z%m]], "plantuml"),
  }),
}

M.msbuild = {
  name = "msbuild",
  filetypes = { "c", "cpp", "cs" },
  method = null.methods.DIAGNOSTICS,
  generator = null.generator({
    command = "msbuild",
    cwd = function(params)
      -- falls back to root if return value is nil
      return vim.fs.dirname(params.bufname)
    end,
    args = {},
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
    on_output = helpers.diagnostics.from_errorformat([=[%f(%l): %t%*[^ ] C%n: %m [%.%#]]=], "msbuild"),
  }),
}

function M.list_registered_providers_names(filetype)
  local s = require("null-ls.sources")
  local available_sources = s.get_available(filetype)
  local registered = {}
  for _, source in ipairs(available_sources) do
    for _ in pairs(source.methods) do
      table.insert(registered, source.name)
    end
  end
  return require("utils.utils").set.new(registered)
end

function M:setup()
  -- See here for configuring builtins
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
  -- See here for list of builtins
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
  local sources = {
    --[[  null.builtins.diagnostics.editorconfig_checker,
		null.builtins.formatting.trim_newlines.with({
			disabled_filetypes = { "rust" }, -- use rustfmt
		}),
		null.builtins.formatting.trim_whitespace.with({
			disabled_filetypes = { "rust" }, -- use rustfmt
		}), ]]
  }
  if vim.fn.executable("vale") > 0 then
    -- Initially run 'vale sync' to download style paths
    -- Check config with 'vale ls-config'
    log.info("NullLs setting up vale...")
    table.insert(
      sources,
      null.builtins.diagnostics.vale.with({
        filetypes = {},
        extra_args = vim.fn.has("unix") > 0 and { [[--config=/home/reinaldo/.config/.vale.ini]] } or {},
        runtime_condition = function(params)
          -- It's really annoying and slow on windows
          -- Register source, but enable it manually
          return vim.b.null_enable_vale == 1
        end,
      })
    )
  end
  if vim.fn.executable("prettierd") > 0 then
    log.info("NullLs setting up prettierd...")
    table.insert(sources, null.builtins.formatting.prettierd)
  elseif vim.fn.executable("prettier") > 0 then
    log.info("NullLs setting up prettier...")
    table.insert(sources, null.builtins.formatting.prettier)
  elseif vim.fn.executable("jq") then
    log.info("NullLs setting up jq...")
    table.insert(sources, null.builtins.formatting.jq)
  elseif vim.fn.executable("python") then
    log.info("NullLs setting up python json_tool...")
    table.insert(sources, null.builtins.formatting.json_tool)
  end
  if vim.fn.executable("mypy") > 0 then
    log.info("NullLs setting up mypy...")
    table.insert(sources, null.builtins.diagnostics.mypy)
  end
  if vim.fn.executable("isort") > 0 then
    log.info("NullLs setting up isort...")
    table.insert(sources, null.builtins.formatting.isort)
  end
  if vim.fn.executable("black") > 0 then
    log.info("NullLs setting up black...")
    table.insert(sources, null.builtins.formatting.black)
  end
  if vim.fn.executable("autopep8") > 0 then
    log.info("NullLs setting up autopep8...")
    table.insert(sources, null.builtins.formatting.autopep8)
  end
  if vim.fn.executable("pylint") > 0 then
    log.info("NullLs setting up pylint...")
    table.insert(sources, null.builtins.diagnostics.pylint)
  end
  if vim.fn.executable("pylama") > 0 then
    log.info("NullLs setting up pylama...")
    table.insert(sources, null.builtins.diagnostics.pylama)
  end
  if vim.fn.executable("stylua") > 0 then
    log.info("NullLs setting up stylua...")
    table.insert(sources, null.builtins.formatting.stylua)
  end
  if vim.fn.executable("shfmt") > 0 then
    log.info("NullLs setting up shfmt...")
    table.insert(sources, null.builtins.formatting.shfmt)
  end
  if vim.fn.executable("shellcheck") > 0 then
    log.info("NullLs setting up shellcheck...")
    table.insert(sources, null.builtins.diagnostics.shellcheck)
  end
  if vim.fn.executable("rustfmt") > 0 then
    log.info("NullLs setting up rustfmt...")
    table.insert(
      sources,
      null.builtins.formatting.rustfmt.with({
        extra_args = { "--edition=2021" },
      })
    )
  end
  if vim.fn.executable("cmake-lint") > 0 then
    log.info("NullLs setting up cmake-lint...")
    table.insert(sources, null.builtins.diagnostics.cmake_lint)
  end
  if vim.fn.executable("cmake-format") > 0 then
    log.info("NullLs setting up cmake-format...")
    table.insert(sources, null.builtins.formatting.cmake_format)
  end
  if vim.fn.executable("clang-format") > 0 then
    log.info("NullLs setting up clang-format...")
    table.insert(
      sources,
      null.builtins.formatting.clang_format.with({
        extra_args = { "-style=file", '-fallback-style="LLVM"' },
      })
    )
  end
  if vim.fn.executable("cppcheck") > 0 then
    log.info("NullLs setting up cppcheck...")
    table.insert(sources, null.builtins.diagnostics.cppcheck)
  end
  if vim.fn.executable("clang-check") > 0 then
    log.info("NullLs setting up clang-check...")
    table.insert(sources, null.builtins.diagnostics.clang_check.with({
      args = {
        "--analyze",
        "--extra-arg=-Xclang",
        "--extra-arg=-analyzer-output=text",
        "--extra-arg=-fno-color-diagnostics",
        "--extra-arg=-std=c++20",
        '--extra-arg=-xc++',
        "-p", "$DIRNAME", 
        "$FILENAME",
      },
    }))
  end
  --[[ if vim.fn.executable("cpplint") > 0 and vim.fn.has("unix") > 0 then
    log.info("NullLs setting up cpplint...")
    table.insert(sources, null.builtins.diagnostics.cpplint)
  end ]]

  null.setup({
    -- Set to "trace" for really big logs
    log_level = "info",
    -- Attach only if current buf has certain lines
    -- TODO: Re-using treesitter's function. It smells funny. Fix it
    should_attach = function()
      return vim.b.ts_disabled == 0
    end,
    debounce = 250,
    default_timeout = 60000,
    diagnostics_format = "(#{s}): #{m}",
    -- TODO: loop through sources to check if there's a formatting source
    -- Only then overwrite mappings.
    -- on_attach = require("config.lsp").on_lsp_attach,
    on_attach = function()
      -- Null ls on demand
      vim.b.null_enable_vale = 0
    end,
    on_exit = nil,
    sources = sources,
  })
  if vim.fn.executable("plantuml") > 0 then
    null.register(self.plantuml)
  end
  if vim.fn.executable("msbuild") > 0 then
    null.register(self.msbuild)
  end
  map:keymaps_sets(self.maps)
end

return M
