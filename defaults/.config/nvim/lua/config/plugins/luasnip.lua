local M = {}

function M:config()
	local ls = require("luasnip")
	local types = require("luasnip.util.types")

	ls.config.set_config({
		-- This tells LuaSnip to remember to keep around the last snippet.
		-- You can jump back into it even if you move outside of the selection
		history = true,

		-- This one is cool cause if you have dynamic snippets, it updates as you type!
		updateevents = "TextChanged,TextChangedI",

		-- Autosnippets:
		enable_autosnippets = false,

		-- Crazy highlights!!
		-- ext_opts = nil,
		ext_opts = {
			[types.choiceNode] = { active = { virt_text = { { "● (c-n)", "GruvboxOrange" } } } },
			[types.insertNode] = { active = { virt_text = { { "●", "GruvboxBlue" } } } },
		},
	})

	ls.filetype_extend("all", { "_" })
	require("luasnip.loaders.from_vscode").lazy_load()
	require("luasnip.loaders.from_snipmate").lazy_load()
	-- Load snippets from my-snippets folder
	-- If path is not specified, luasnip will look for the `snippets` directory
	-- in rtp (for custom-snippet probably
	-- -- `~/.config/nvim/snippets`).
	require("luasnip.loaders.from_snipmate").load({
		path = { vim.fn.stdpath("config") .. [[/snippets/]] },
	})

	local opts = { silent = true, desc = "snippet_expand_or_jumpable" }
	vim.keymap.set({ "i", "s" }, "<c-k>", function()
		if ls.expand_or_jumpable() then
			ls.expand_or_jump()
		end
	end, opts)

	opts.desc = "snippet_jumpable"
	vim.keymap.set({ "i", "s" }, "<c-j>", function()
		if ls.jumpable(-1) then
			ls.jump(-1)
		end
	end, opts)

	opts.desc = "snippet_choice_active"
	vim.keymap.set({ "i", "s" }, "<c-n>", function()
		require("luasnip.extras.select_choice")()
	end, opts)
end

return M
