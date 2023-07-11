---@module markdown after ftplugin
---@author Reinaldo Molina

if vim.b.did_markdown_ftplugin then
  return
end

vim.b.did_markdown_ftplugin = 1

local u = require("utils.utils")
local preview = function()
  local o = vim.fn.expand("%:p:r") .. ".html"
  u.browser.open_file_async(o)
end

local _filetype = { "html", "docx", "pdf" }
local function _validate_filetypes(filetype)
  return vim.tbl_contains(_filetype, filetype)
end

local render = function(filetype)
  vim.validate({ filetype = { filetype, _validate_filetypes, "one of: " .. vim.inspect(_filetype) } })
  local f = vim.fn.expand("%:p")
  local o = vim.fn.expand("%:p:r") .. "." .. filetype
  local cmd = { "pandoc", f, "-o", o }
  u.term.exec(cmd)
end

if vim.g.no_plugin_maps == nil and vim.g.no_markdown_maps == nil then
  local vks = vim.keymap.set
		vks("n", "<plug>make_file", function()
			render("html")
		end, { desc = "pandoc-render-html" })
  vks("n", "<plug>preview", preview, { desc = "file_preview" })
end
