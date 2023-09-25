local M = {}
local utl = require("utils.utils")
local fs = require("utils.filesystem")

M.holograms = {}

M.open_first_visible_image = function()
  local img = fs.search_for_first_visible_source(fs.sources)
  if img == nil then
    vim.print("No sources found")
    return
  end

  utl.term.open_file(img)
end

M.toggle_hologram_images = function()
	local hol_ok, hol = pcall(require, "hologram")
	if not hol_ok then
		vim.api.nvim_err_writeln("hologram not installed")
		return
	end

  local img = fs.search_for_first_visible_source(fs.sources)
  if img == nil then
    vim.print("No sources found")
    return
  end

	local buf = vim.api.nvim_get_current_buf()
	local Image = require("hologram.image")
  local image = Image:new(img, {}, false)
  image:display(vim.fn.line("w0") + 1, 0, buf, {})
  table.insert(M.holograms, image)

	-- Setup autocmd to clean up hologram images
	vim.api.nvim_create_autocmd({ "BufWinLeave", "CursorMoved" }, {
		callback = function(au)
			for _, i in pairs(M.holograms) do
				i:delete(buf, { free = true })
			end
			M.holograms = {}
		end,
		buffer = buf,
		once = true,
	})
end

return {
	"giusgad/hologram.nvim",
	event = "VeryLazy",
	opts = {
		auto_display = false,
	},
	toggle_hologram_images = M.toggle_hologram_images,
  open_first_visible_image = M.open_first_visible_image,
}
