local dap = {
	"mfussenegger/nvim-dap",
  ft = {"lua"},
	keys = {
		{ "n", "<F8>", [[:lua require"dap".toggle_breakpoint()<CR>]], { noremap = true } },
		{ "n", "<F9>", [[:lua require"dap".continue()<CR>]], { noremap = true } },
		{ "n", "<F10>", [[:lua require"dap".step_over()<CR>]], { noremap = true } },
		{ "n", "<S-F10>", [[:lua require"dap".step_into()<CR>]], { noremap = true } },
		{ "n", "<F12>", [[:lua require"dap.ui.widgets".hover()<CR>]], { noremap = true } },
		{ "n", "<F5>", [[:lua require"osv".launch({port = 8086})<CR>]], { noremap = true } },
	},
	config = function()
		local dap = require("dap")
		dap.configurations.lua = {
			{
				type = "nlua",
				request = "attach",
				name = "Attach to running Neovim instance",
			},
		}

		dap.adapters.nlua = function(callback, config)
			callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
		end
	end,
	dependencies = {
		"jbyuki/one-small-step-for-vimkind",
	},
}

return dap
