local log = require("utils.log")
local fmt = string.format
local utl = require("utils.utils")
local line = require("config.plugins.lualine")
local map = require("config.mappings")
local vks = vim.keymap.set
local api = vim.api

local function setup_flux()
  local f = require("plugin.flux")
  f:setup({
    callback = set_colorscheme,
  })
  local id = api.nvim_create_augroup("FluxLike", { clear = true })
  if vim.fn.has("unix") > 0 and vim.fn.executable("luajit") > 0 then
    vim.g.flux_enabled = 0

    api.nvim_create_autocmd("VeryLazy", {
      callback = function()
        vim.defer_fn(function()
          f:check()
        end, 0) -- Defered for live reloading
      end,
      pattern = "*",
      desc = "Flux",
      once = true,
      group = id,
    })
    return
  end
  api.nvim_create_autocmd("VeryLazy", {
    callback = function()
      vim.defer_fn(function()
        vim.fn["flux#Flux"]()
      end, 0) -- Defered for live reloading
    end,
    pattern = "*",
    desc = "Flux",
    group = id,
  })

  vim.g.flux_enabled = 1
  vim.g.flux_api_lat = 27.972572
  vim.g.flux_api_lon = -82.796745

  vim.g.flux_night_time = 2000
  vim.g.flux_day_time = 700
end

return {
  -- the colorscheme should be available when starting Neovim
  {
    "catppuccin/nvim",
    init = function()
      M.setup_flux()
    end,
    cmd = { "CatppuccinCompile", "CatppuccinStatus", "Catppuccin", "CatppuccinClean" },
    config = function()
      local catppuccin = require("catppuccin")
      catppuccin.setup({
        compile = {
          enabled = true,
          -- .. [[/site/plugin/catppuccin]]
          path = vim.fn.stdpath("data") .. [[/catppuccin]],
          suffix = "_compiled",
        },
        integrations = {
          indent_blankline = {
            enabled = true,
            colored_indent_levels = true,
          },
          dap = {
            enabled = vim.fn.has("unix") > 0 and true or false,
            enable_ui = vim.fn.has("unix") > 0 and true or false,
          },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
          noice = true,
          treesitter_context = true,
          telescope = true,
          which_key = true,
          dashboard = true,
          vim_sneak = true,
          markdown = true,
          ts_rainbow = true,
          notify = true,
          symbols_outline = true,
        },
      })
    end,
  },
}
