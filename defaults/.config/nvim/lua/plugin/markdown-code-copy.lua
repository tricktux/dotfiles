local M = {}

-- Pinned target (any buffer)
M.targets = {
  pinned = nil,
}

-- Function to get visual selection using current visual mode
local function get_current_visual_selection()
  local start_pos = vim.fn.getpos('v')
  local end_pos = vim.fn.getcurpos()

  local start_line, end_line
  if
      start_pos[2] > end_pos[2]
      or (start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3])
  then
    start_line = end_pos[2]
    end_line = start_pos[2]
  else
    start_line = start_pos[2]
    end_line = end_pos[2]
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  return lines, start_line
end

-- Function to get visual selection from marks
local function get_visual_selection_from_marks()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  return lines, start_line
end

-- Check if buffer is a terminal
local function is_terminal_buffer(bufnr)
  bufnr = bufnr or 0
  return vim.bo[bufnr].buftype == 'terminal'
end

-- Detect language from filetype
local function get_language_from_filetype(filetype, is_terminal)
  if is_terminal then
    return 'shell'
  end

  local lang_map = {
    ['python'] = 'python',
    ['lua'] = 'lua',
    ['javascript'] = 'javascript',
    ['typescript'] = 'typescript',
    ['rust'] = 'rust',
    ['go'] = 'go',
    ['c'] = 'c',
    ['cpp'] = 'cpp',
    ['java'] = 'java',
    ['sh'] = 'bash',
    ['bash'] = 'bash',
    ['zsh'] = 'bash',
    ['vim'] = 'vim',
    ['json'] = 'json',
    ['yaml'] = 'yaml',
    ['toml'] = 'toml',
    ['html'] = 'html',
    ['css'] = 'css',
    ['scss'] = 'scss',
    ['sql'] = 'sql',
    ['dockerfile'] = 'dockerfile',
    ['make'] = 'makefile',
  }

  return lang_map[filetype] or filetype or 'text'
end

-- Get comment prefix from commentstring
local function get_comment_prefix()
  local commentstring = vim.bo.commentstring
  if not commentstring or commentstring == '' then
    return '#'
  end

  local comment_prefix = commentstring:match('^(.-)%%s')
  if comment_prefix then
    return comment_prefix:gsub('%s+$', '')
  end

  return commentstring:gsub('%s+$', '')
end

-- Ensure buffer is visible in a window, opens a vsplit if not
local function ensure_buffer_visible(bufnr)
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(winid) == bufnr then
      return winid
    end
  end

  vim.cmd('vsplit')
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, bufnr)
  return new_win
end

-- Build the markdown code block lines
local function build_code_block(
    selected_lines,
    start_line,
    filetype,
    current_file,
    is_terminal
)
  local language = get_language_from_filetype(filetype, is_terminal)
  local code_block = { '' }

  table.insert(code_block, '```' .. language)

  if not is_terminal then
    local comment_prefix = get_comment_prefix()
    local relative_file = vim.fn.fnamemodify(current_file, ':.')
    table.insert(
      code_block,
      string.format('%s %s:%d', comment_prefix, relative_file, start_line)
    )
  end

  for _, line in ipairs(selected_lines) do
    table.insert(code_block, line)
  end

  table.insert(code_block, '```')
  table.insert(code_block, '')

  return code_block
end

-- Insert code block into target buffer at its cursor position
local function insert_into_buffer(target_bufnr, code_block)
  local target_win = ensure_buffer_visible(target_bufnr)
  local insert_line = vim.api.nvim_win_get_cursor(target_win)[1]

  vim.api.nvim_buf_set_lines(
    target_bufnr,
    insert_line,
    insert_line,
    false,
    code_block
  )
  vim.api.nvim_set_current_win(target_win)
  vim.api.nvim_win_set_cursor(target_win, { insert_line + #code_block, 0 })
end

-- Telescope picker listing ALL loaded buffers (including codecompanion)
local function pick_target_buffer(callback)
  local ok, pickers = pcall(require, 'telescope.pickers')
  if not ok then
    vim.notify('Telescope is required for buffer picking', vim.log.levels.ERROR)
    return
  end
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local entries = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if
        vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_is_valid(bufnr)
    then
      local name = vim.api.nvim_buf_get_name(bufnr)
      local ft = vim.bo[bufnr].filetype
      -- Skip truly anonymous/empty buffers
      if name ~= '' or ft ~= '' then
        local display_name = name ~= '' and vim.fn.fnamemodify(name, ':.')
            or '[No Name]'
        table.insert(entries, {
          bufnr = bufnr,
          name = display_name,
          ft = ft ~= '' and ft or '?',
        })
      end
    end
  end

  pickers
      .new({}, {
        prompt_title = 'Pin Target Buffer',
        finder = finders.new_table({
          results = entries,
          entry_maker = function(entry)
            local display =
                string.format('[%d] %s  (%s)', entry.bufnr, entry.name, entry.ft)
            return {
              value = entry,
              display = display,
              ordinal = display,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local sel = action_state.get_selected_entry()
            if sel then
              callback(sel.value.bufnr)
            end
          end)
          return true
        end,
      })
      :find()
end

-- Capture selection context BEFORE any mode/state changes
local function capture_selection(use_current_visual)
  local selected_lines, start_line
  if use_current_visual then
    selected_lines, start_line = get_current_visual_selection()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<Esc>', true, false, true),
      'n',
      true
    )
  else
    selected_lines, start_line = get_visual_selection_from_marks()
  end

  return {
    lines = selected_lines,
    start_line = start_line,
    file = vim.api.nvim_buf_get_name(0),
    filetype = vim.bo.filetype,
    is_terminal = is_terminal_buffer(0),
    comment_prefix = get_comment_prefix(),
  }
end

-- Pin a target buffer via Telescope
function M.set_target()
  pick_target_buffer(function(bufnr)
    M.targets.pinned = bufnr
    local name = vim.api.nvim_buf_get_name(bufnr)
    local label = name ~= '' and vim.fn.fnamemodify(name, ':t')
        or vim.bo[bufnr].filetype
    vim.notify('Target pinned: ' .. label, vim.log.levels.INFO)
  end)
end

-- Send selection to pinned target; prompt to pick one if none is set
function M.copy_to_pinned(use_current_visual)
  local ctx = capture_selection(use_current_visual)

  if not ctx.is_terminal and ctx.file == '' then
    vim.notify('Current buffer has no file path', vim.log.levels.WARN)
    return
  end

  if #ctx.lines == 0 then
    vim.notify('No text selected', vim.log.levels.WARN)
    return
  end

  local code_block = build_code_block(
    ctx.lines,
    ctx.start_line,
    ctx.filetype,
    ctx.file,
    ctx.is_terminal
  )

  local function do_send(target_bufnr)
    M.targets.pinned = target_bufnr
    insert_into_buffer(target_bufnr, code_block)

    local source_label = ctx.is_terminal and 'terminal'
        or vim.fn.fnamemodify(ctx.file, ':t')
    local tname = vim.api.nvim_buf_get_name(target_bufnr)
    local target_label = tname ~= '' and vim.fn.fnamemodify(tname, ':t')
        or vim.bo[target_bufnr].filetype
    vim.notify(
      string.format('Code from %s → %s', source_label, target_label),
      vim.log.levels.INFO
    )
  end

  if M.targets.pinned and vim.api.nvim_buf_is_valid(M.targets.pinned) then
    do_send(M.targets.pinned)
  else
    -- No valid target: pick one, then send
    pick_target_buffer(function(bufnr)
      do_send(bufnr)
    end)
  end
end

function M.setup()
  -- Pick and pin any buffer as target
  vim.keymap.set('n', '<leader>cm', M.set_target, {
    desc = 'Pin a buffer as copy target',
  })

  -- Send visual selection to pinned target (prompt if none)
  vim.keymap.set('v', '<leader>cc', function()
    M.copy_to_pinned(true)
  end, { desc = 'Copy selection to pinned target buffer' })

  -- Send current line to pinned target (prompt if none)
  vim.keymap.set('n', '<leader>cc', function()
    local line_nr = vim.api.nvim_win_get_cursor(0)[1]
    local current_line = vim.api.nvim_get_current_line()
    vim.api.nvim_buf_set_mark(0, '<', line_nr, 0, {})
    vim.api.nvim_buf_set_mark(0, '>', line_nr, #current_line, {})
    M.copy_to_pinned(false)
  end, { desc = 'Copy current line to pinned target buffer' })

  -- Auto-clear pinned target if the buffer is deleted
  vim.api.nvim_create_autocmd('BufDelete', {
    callback = function(ev)
      if M.targets.pinned == ev.buf then
        M.targets.pinned = nil
        vim.notify(
          'Pinned target buffer was closed and cleared',
          vim.log.levels.WARN
        )
      end
    end,
    desc = 'Clear pinned target on buffer delete',
  })
end

return M
