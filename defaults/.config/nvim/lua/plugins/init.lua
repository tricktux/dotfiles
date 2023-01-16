local log = require("utils.log")
local fmt = string.format
local utl = require("utils.utils")
local line = require("plugins.lualine")
local map = require("mappings")
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
  {
    "catppuccin/nvim",
    init = function()
      M.setup_flux()
    end,
    name = "catppuccin",
    cmd = { "CatppuccinCompile", "CatppuccinStatus", "Catppuccin", "CatppuccinClean" },
    opts = {
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
    },
  },
  {
    -- TODO: move it to telescope.nvim
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    dependencies = { "nvim-lua/telescope.nvim" },
    config = function()
      local has_telescope, telescope = pcall(require, "telescope")

      if has_telescope then
        telescope.load_extension("notify")
        local opts = { silent = true, desc = "notify" }
        vks("n", "<leader>fn", telescope.extensions.notify.notify, opts)
      end

      vim.notify = require("notify")
      vim.notify.setup({
        -- Minimum level to show
        level = "info",

        -- Animation style (see below for details)
        stages = "fade_in_slide_out",

        -- Function called when a new window is opened, use for changing win settings/config
        on_open = nil,

        -- Function called when a window is closed
        on_close = nil,

        -- Render function for notifications. See notify-render()
        render = "default",

        -- Default timeout for notifications
        timeout = 500,

        -- Max number of columns for messages
        max_width = nil,
        -- Max number of lines for a message
        max_height = nil,

        -- For stages that change opacity this is treated as the highlight behind the window
        -- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
        background_colour = "#000000",

        -- Minimum width for notification windows
        minimum_width = 50,

        -- Icons for the different levels
        icons = {
          ERROR = "",
          WARN = "",
          INFO = "",
          DEBUG = "",
          TRACE = "✎",
        },
      })
    end,
  },
  {
    -- TODO: move it to treesitter.nvim
    "danymat/neogen",
    keys = {
      {
        "<leader>og",
        function()
          require("neogen").generate()
        end,
        desc = "generate_neogen",
      },
      {
        "<leader>oGf",
        function()
          require("neogen").generate({ type = "func" })
        end,
        desc = "generate_neogen_function",
      },
      {
        "<leader>oGc",
        function()
          require("neogen").generate({ type = "class" })
        end,
        desc = "generate_neogen_class",
      },
      {
        "<leader>oGi",
        function()
          require("neogen").generate({ type = "file" })
        end,
        desc = "generate_neogen_file",
      },
      {
        "<leader>oGt",
        function()
          require("neogen").generate({ type = "type" })
        end,
        desc = "generate_neogen_type",
      },
    },
    opts = {
      enabled = true,
      snippet_engine = "luasnip",
      languages = {
        csharp = {
          template = {
            annotation_convention = "xmldoc",
          },
        },
      },
    },
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
}
