local log = require("utils.log")
local map = require("mappings")
local vks = vim.keymap.set

local maps = {}
maps.mode = "n"
maps.prefix = "<leader>tn"
maps.opts = { silent = true }
maps.mappings = {
  d = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .. "'", vim.log.levels.WARN)
        return
      end
      vim.ui.select(srcs, {
        prompt = "Select source to disable:",
        format_item = nil,
      }, function(choice)
        require("null-ls").disable(choice)
      end)
    end,
    "disable_source",
  },
  e = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .. "'", vim.log.levels.WARN)
        return
      end
      vim.ui.select(srcs, {
        prompt = "Select source to enable:",
        format_item = nil,
      }, function(choice)
        require("null-ls").enable(choice)
      end)
    end,
    "enable_source",
  },
  s = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .. "'", vim.log.levels.WARN)
        return
      end
      vim.ui.select(srcs, {
        prompt = "Select source to toggle:",
        format_item = nil,
      }, function(choice)
        require("null-ls").toggle(choice)
      end)
    end,
    "toggle_source",
  },
  E = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .. "'", vim.log.levels.WARN)
        return
      end
      for _, v in pairs(srcs) do
        require("null-ls").enable(v)
      end
    end,
    "disable_all",
  },
  D = {
    function()
      local ft = vim.opt.filetype:get()
      local srcs = get_sources_for_filetype(ft)
      if vim.tbl_isempty(srcs) then
        vim.notify("No null-ls sources installed for '" .. ft .. "'", vim.log.levels.WARN)
        return
      end
      for _, v in pairs(srcs) do
        require("null-ls").disable(v)
      end
    end,
    "disable_all",
  },
  v = {
    function()
      vim.b.null_enable_vale = 1
      require("null-ls").enable("vale")
    end,
    "vale_enable",
  },
  V = {
    function()
      vim.b.null_enable_vale = 0
      require("null-ls").disable("vale")
    end,
    "vale_disable",
  },
}

--- Dependencies:
local function get_plantuml()
  return {
    name = "plantuml",
    filetypes = { "plantuml" },
    method = require("null-ls").methods.DIAGNOSTICS,
    generator = require("null-ls").generator({
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
      on_output = require("null-ls.helpers").diagnostics.from_errorformat([[%EError line %l in file: %f,%Z%m]],
        "plantuml"),
    }),
  }
end

local function get_msbuild()
  return {
    name = "msbuild",
    filetypes = { "c", "cpp", "cs" },
    method = require("null-ls").methods.DIAGNOSTICS,
    generator = require("null-ls").generator({
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
      on_output = require("null-ls.helpers").diagnostics.from_errorformat([=[%f(%l): %t%*[^ ] C%n: %m [%.%#]]=],
        "msbuild"),
    }),
  }
end

local function setup()
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
  local null = require("null-ls")
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
    log_level = "trace",
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
      -- Formatting mappings
      local opts = { desc = "formatting" }
      vks("n", "<localleader>f", function() vim.lsp.buf.format({ async = false }) end, opts)
      opts.desc = "range_formatting"
      vks("n", "<localleader>F", vim.lsp.buf.range_formatting, opts)
      opts.desc = "show_line_diagnostics"
      vks("n", "<localleader>n", vim.diagnostic.open_float, opts)
      opts.desc = "lsp_hover"
      vks("n", "<localleader>h", vim.lsp.buf.hover, opts)
    end,
    on_exit = nil,
    sources = sources,
  })
  if vim.fn.executable("plantuml") > 0 then
    null.register(get_plantuml())
  end
  if vim.fn.executable("msbuild") > 0 then
    null.register(get_msbuild())
  end
  map:keymaps_sets(maps)
end

return {
  "jose-elias-alvarez/null-ls.nvim",
  event = "BufReadPre",
  config = function()
    setup()
  end,
}
