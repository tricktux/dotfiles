local log = require("utils.log")
local null = require("null-ls")
local helpers = require("null-ls.helpers")

local M = {}

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

function M:setup()
	-- See here for configuring builtins
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
	-- See here for list of builtins
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
	local sources = {
		null.builtins.diagnostics.editorconfig_checker,
	}
	if vim.fn.executable("python") > 0 then
		log.info("NullLs setting up json_tool...")
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

	null.setup({
		debug = true,
		diagnostics_format = "(#{s}): #{m}",
		on_attach = require("config.lsp").on_lsp_attach,
		root_dir = nil, -- It was interfering with projector
		sources = sources,
	})
	if vim.fn.executable("plantuml") > 0 then
		null.register(self.plantuml)
	end
	if vim.fn.has("win32") > 0 then
		null.register(self.msbuild)
	end
end

return M
