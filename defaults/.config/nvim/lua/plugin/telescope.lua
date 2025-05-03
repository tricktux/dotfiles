local map = require('mappings')
local utl = require('utils.utils')

local M = {}

M.cust_path_display = function(opts, path)
  if utl.has_win then
    path = path:gsub('/', '\\')
  end -- normalize paths
  local tail = require('telescope.utils').path_tail(path)
  return string.format('%-35s %s', tail, path)
end

M.cust_layout_config = { height = 0.5, width = 0.6 }

M.cust_files_opts = {
  previewer = false,
  layout_config = M.cust_layout_config,
  path_display = M.cust_path_display,
}

M.cust_buff_opts = function()
  return {
    show_all_buffers = true,
    only_cwd = false,
    sort_mru = true,
    sort_lastused = true,
    previewer = false,
    path_display = M.cust_path_display,
    layout_config = M.cust_layout_config,
  }
end

function M.set_lsp_mappings()
  local opts = { buffer = true, silent = true }
  local prefix = '<localleader>lt'
  local ts = require('telescope.builtin')
  local mappings = {
    r = { ts.lsp_references, 'tele_references' },
    d = { ts.lsp_definitions, 'tele_definitions' },
    i = { ts.lsp_implementations, 'tele_implementations' },
    s = { ts.lsp_document_symbols, 'tele_document_symbols' },
    w = { ts.lsp_workspace_symbols, 'tele_workspace_symbols' },
  }

  map.keymaps_set(mappings, 'n', opts, prefix)

  -- Override default mappings with telescope lsp intelligent analogous
  prefix = '<localleader>'
  mappings = {
    D = {
      function()
        vim.cmd([[vsplit]])
        ts.lsp_definitions()
      end,
      'tele_lsp_definition_split',
    },
    d = { ts.lsp_definitions, 'tele_lsp_definition' },
    r = { ts.lsp_references, 'tele_lsp_references' },
  }

  map.keymaps_set(mappings, 'n', opts, prefix)
end

function M.find_files_sanitize(path)
  vim.validate('path', path, 'string')
  local Path = require('plenary.path')

  local ppath = Path:new(path)
  if not ppath:is_dir() then
    vim.notify('telescope.lua: path not found: ' .. ppath:absolute(), vim.log.levels.ERROR)
    return
  end
  local opts = M.cust_files_opts
  local spath = ppath:absolute()
  opts['prompt_title'] = 'Files in "' .. spath .. '"...'
  opts['cwd'] = spath
  opts['find_command'] = utl.fd.file_cmd
  return opts
end

function M.find_files_yank(_prompt_bufnr)
  local actions = require('telescope.actions')
  local p = require('telescope.actions.state').get_selected_entry().path
  -- put the selected entry in the clipboard register
  vim.fn.setreg('p', p)
  vim.fn.setreg('*', p)
  vim.fn.setreg('+', p)
  -- close search window
  actions.close(_prompt_bufnr)
  print('Path copied to clipboard: ' .. p)
  -- Telescope runs async, in case you want to do something with special
  -- with this filename subscribe to this autocommand, value is in
  -- register p
  vim.cmd.doautocmd('User TelescopeFindFilesYankPost')
end

function M.file_fuzzer_yank(path)
  local opts = M.find_files_sanitize(path)

  opts['attach_mappings'] = function(_, map)
    map('i', '<cr>', M.find_files_yank)
    -- needs to return true if you want to map default_mappings and
    -- false if not
    return true
  end
  require('telescope.builtin').find_files(opts)
end

function M.file_fuzzer(path)
  local opts = M.find_files_sanitize(path)

  opts['attach_mappings'] = function(_, map)
    map('i', '<c-y>', M.find_files_yank)
    -- needs to return true if you want to map default_mappings and
    -- false if not
    return true
  end
  require('telescope.builtin').find_files(opts)
end

return M
