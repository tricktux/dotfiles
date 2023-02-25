local utl = require("utils.utils")

local M = {}

local check_backspace = function()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

function M:setup()
	local win_sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer", keyword_length = 3 },
		{ name = "luasnip" },
		{ name = "calc" },
		{ name = "orgmode" },
	}
	local unix_sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer", keyword_length = 3 },
		{ name = "luasnip" },
		{ name = "calc" },
		{ name = "path" },
		{ name = "orgmode" },
	}
	local cp_ok, _ = pcall(require, "copilot_cmp")
	if cp_ok then
		table.insert(unix_sources, 1, { name = "copilot" })
	end

	local cmp = require("cmp")
	local prev = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.select_prev_item()
		else
			fallback()
		end
	end, {
		"i",
		"s",
	})
	local next = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.select_next_item()
		elseif check_backspace() then
			fallback()
		else
			fallback()
		end
	end, {
		"i",
		"s",
	})
	cmp.setup({
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		completion = {
			keyword_length = 1,
		},
		mapping = cmp.mapping.preset.insert({
			["<C-u>"] = cmp.mapping.scroll_docs(-4),
			["<C-d>"] = cmp.mapping.scroll_docs(4),
			["<C-p>"] = prev,
			["<C-n>"] = next,
			-- Move cursor
			["<C-f>"] = cmp.config.disable,
			["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
			["<C-q>"] = cmp.mapping({
				i = cmp.mapping.abort(),
				c = cmp.mapping.close(),
			}),
			-- Used by snipets
			["<C-j>"] = cmp.config.disable,
			["<C-l>"] = cmp.config.disable,
			["<C-k>"] = cmp.config.disable, -- used for snippets
			["<CR>"] = cmp.config.disable,
			["<Tab>"] = next,
			["<S-Tab>"] = prev,
		}),
		sources = utl.has_unix and unix_sources or win_sources,
		formatting = {
			format = function(_, item)
				local icons = require("utils.utils").icons.kinds
				if icons[item.kind] then
					item.kind = icons[item.kind] .. item.kind
				end
				return item
			end,
		},
		window = {
			documentation = {
				border = "rounded",
			},
			completion = {
				border = "rounded",
			},
		},
		experimental = {
			-- Let's play with this for a day or two
			ghost_text = false,
		},
	})
end

return {
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		config = function()
			M:setup()
		end,
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-calc",
			"saadparwaiz1/cmp_luasnip",
		},
	},
}
