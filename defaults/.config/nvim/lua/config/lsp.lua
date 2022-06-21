local utl = require("utils.utils")
local log = require("utils.log")
local vks = vim.keymap.set

local function setup_fidget()
	require("fidget").setup({
		text = {
			spinner = "dots", -- animation shown when tasks are ongoing
			done = "✔", -- character shown when all tasks are complete
			commenced = "Started", -- message shown when task starts
			completed = "Completed", -- message shown when task completes
		},
		align = {
			bottom = true, -- align fidgets along bottom edge of buffer
			right = true, -- align fidgets along right edge of buffer
		},
		timer = {
			spinner_rate = 125, -- frame rate of spinner animation, in ms
			fidget_decay = 2000, -- how long to keep around empty fidget, in ms
			task_decay = 1000, -- how long to keep around completed task, in ms
		},
		fmt = {
			leftpad = true, -- right-justify text in fidget box
			-- function to format fidget title
			fidget = function(fidget_name, spinner)
				return string.format("%s %s", spinner, fidget_name)
			end,
			-- function to format each task line
			task = function(task_name, message, percentage)
				return string.format(
					"%s%s [%s]",
					message,
					percentage and string.format(" (%s%%)", percentage) or "",
					task_name
				)
			end,
		},
	})
end

local function set_lsp_options(capabilities, bufnr)
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
	vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
end

local function set_lsp_mappings(capabilities, bufnr)
	local opts = { silent = true, buffer = bufnr }
  local prefix = "<localleader>l"
	local lsp = vim.lsp
	local diag = vim.diagnostic
	local list = function() vim.pretty_print(vim.lsp.buf.list_workspace_folders()) end
	local workspace = {
		a = { lsp.buf.add_workspace_folder, "add_workspace_folder" },
		r = { lsp.buf.remove_workspace_folder, "remove_workspace_folder" },
		l = { list, "list_folders" },
	}
  for k,v in pairs(workspace) do
    if v[1] ~= nil then
      opts.desc = v[2]
      vks('n', prefix .. 'w' .. k, v[1], opts)
    end
  end
	local mappings = {
		r = { lsp.buf.rename, "rename" },
		e = { lsp.buf.declaration, "declaration" },
		d = { lsp.buf.definition, "definition" },
		h = { lsp.buf.hover, "hover" },
		i = { lsp.buf.implementation, "implementation" },
		H = { lsp.buf.signature_help, "signature_help" },
		D = { lsp.buf.type_definition, "type_definition" },
		R = { lsp.buf.references, "references" },
		S = { lsp.stop_all_clients, "stop_all_clients" },
		n = { vim.diagnostic.open_float, "show_line_diagnostics" },
		l = { lsp.diagnostic.setloclist, "set_loclist" },
	}

  for k,v in pairs(mappings) do
    if v[1] ~= nil then
      opts.desc = v[2]
      vks('n', prefix .. 'w' .. k, v[1], opts)
    end
  end

	-- Override default mappings with lsp intelligent analougous
	prefix = "]l"
  opts.desc = "diagnostic_next"
  vks('n', prefix, diag.goto_next, opts)
	prefix = "[l"
  opts.desc = "diagnostic_prev"
  vks('n', prefix, diag.goto_prev, opts)
	prefix = "<localleader>"
	mappings = {
		D = {
			function()
				vim.cmd([[vsplit]])
				lsp.buf.definition()
			end,
			"lsp_definition_split",
		},
		r = { lsp.buf.rename, "lsp_rename" },
		d = { lsp.buf.definition, "lsp_definition" },
		u = { lsp.buf.references, "references" },
		n = { vim.diagnostic.open_float, "show_line_diagnostics" },
		h = { lsp.buf.hover, "hover" },
	}

	-- Set some keybinds conditional on server capabilities
	local fmt = vim.fn.has("nvim-0.8") > 0 and function()
		lsp.buf.format({ async = false })
	end or lsp.buf.formatting
	mappings.f = { fmt, "formatting" }
	mappings.F = { lsp.buf.range_formatting, "range_formatting" }

  for k,v in pairs(mappings) do
    if v[1] ~= nil then
      opts.desc = v[2]
      vks('n', prefix .. k, v[1], opts)
    end
  end

	require("config.plugins.telescope").set_lsp_mappings(bufnr)
end

-- Abstract function that allows you to hook and set settings on a buffer that
-- has lsp server support
local function on_lsp_attach(client_id, bufnr)
	if vim.b.did_on_lsp_attach == 1 then
		return
	end

	vim.b.did_on_lsp_attach = 1

	local cap = vim.fn.has("nvim-0.8") and client_id.server_capabilities or client_id.resolved_capabilities
	set_lsp_mappings(cap, bufnr)
	set_lsp_options(cap, bufnr)
	require("config.plugins.dap"):set_mappings(bufnr)

	require("lsp_signature").on_attach()
end

local function on_clangd_attach(client_id, bufnr)
	if vim.b.did_on_lsp_attach == 1 then
		-- Setup already done in this buffer
		log.debug("on_lsp_attach already setup")
		return
	end

	log.debug("Setting up on_clangd_attach")
	log.debug("client_id = ", client_id)
	local opts = { silent = true, buffer = true, desc = "clangd_switch_source_header" }
	vim.keymap.set("n", "<localleader>a", [[<cmd>ClangdSwitchSourceHeader<cr>]], opts)
	opts.desc = "clangd_switch_source_header"
	vim.keymap.set("n", "<localleader>A", [[<cmd>vs<cr><cmd>ClangdSwitchSourceHeader<cr>]], opts)
	return on_lsp_attach(client_id, bufnr)
end

local function diagnostic_config()
	local opts = {
		virtual_text = { source = "if_many" },
		underline = true,
		signs = true,
		update_in_insert = false,
		float = { source = "if_many" },
	}
	vim.diagnostic.config(opts)
	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		pattern = "*",
		callback = function()
			vim.diagnostic.setqflist({ open = false })
			vim.diagnostic.setloclist({ open = false })
		end,
	})
end

-- TODO
-- Maybe set each server to its own function?
local function lsp_set()
	-- Notice not all configs have a `callbacks` setting
	local nvim_lsp = require("lspconfig")

	diagnostic_config()

	-- vim.lsp.set_log_level("debug")
	setup_fidget()

	local cmp_lsp = require("cmp_nvim_lsp")

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = cmp_lsp.update_capabilities(capabilities)
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities.offsetEncoding = "utf-8" -- Set the same encoding for all servers

	local flags = { allow_incremental_sync = true, debounce_text_changes = 150 }

	-- Unbearably slow
	if vim.fn.executable("omnisharp") > 0 then
		log.info("setting up the omnisharp lsp...")
		local pid = tostring(vim.fn.getpid())
		nvim_lsp.omnisharp.setup({
			on_attach = on_lsp_attach,
			flags = flags,
			filetypes = { "cs" },
			cmd = { "omnisharp", "--languageserver", "--hostPID", pid },
			root_dir = nvim_lsp.util.root_pattern(".vs", "*.csproj", "*.sln"),
			capabilities = capabilities,
		})
	end

	if vim.fn.executable("pyright-langserver") > 0 then
		log.info("setting up the pyright lsp...")
		nvim_lsp.pyright.setup({
			on_attach = on_lsp_attach,
			flags = flags,
			capabilities = capabilities,
		})
	end

	if vim.fn.executable("clangd") > 0 then
		log.info("setting up the clangd lsp...")
		local cores = utl.has_win() and os.getenv("NUMBER_OF_PROCESSORS") or table.concat(vim.fn.systemlist("nproc"))

		nvim_lsp.clangd.setup({
			init_options = { clangdFileStatus = false },
			on_attach = on_clangd_attach,
			flags = flags,
			filetypes = { "c", "cpp" },
			capabilities = capabilities,
			cmd = {
				"clangd",
				"--all-scopes-completion=true",
				"--background-index=true",
				"--clang-tidy=true",
				"--completion-style=detailed",
				"--fallback-style=LLVM",
				"--pch-storage=memory",
				"--header-insertion=iwyu",
				"-j=" .. cores,
				"--header-insertion-decorators=false",
			},
		})
	end

	if vim.fn.executable("rust-analyzer") > 0 then
		nvim_lsp.rust_analyzer.setup({
			on_attach = on_lsp_attach,
			flags = flags,
			capabilities = capabilities,
			settings = {
				["rust-analyzer"] = {
					assist = {
						importGranularity = "module",
						importPrefix = "by_self",
					},
					cargo = {
						loadOutDirsFromCheck = true,
					},
					procMacro = {
						enable = true,
					},
				},
			},
		})
	end
end

return { setup = lsp_set, on_lsp_attach = on_lsp_attach }
