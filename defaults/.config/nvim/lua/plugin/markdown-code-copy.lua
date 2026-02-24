local M = {}

-- Pinned targets
M.targets = {
  markdown = nil,
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

  -- Not visible: open in a vertical split
  vim.cmd('vsplit')
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, bufnr)
  return new_win
end

-- Auto-detect the codecompanion buffer
local function find_codecompanion_buffer()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_loaded(bufnr)
      and vim.bo[bufnr].filetype == 'codecompanion'
    then
      return bufnr
    end
  end
  return nil
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

-- Shared copy logic used by both markdown and codecompanion
local function copy_to_target(use_current_visual, target_bufnr, target_label)
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

  local current_file = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local is_terminal = is_terminal_buffer(0)

  if not is_terminal and current_file == '' then
    vim.notify('Current buffer has no file path', vim.log.levels.WARN)
    return
  end

  if #selected_lines == 0 then
    vim.notify('No text selected', vim.log.levels.WARN)
    return
  end

  local code_block = build_code_block(
    selected_lines,
    start_line,
    filetype,
    current_file,
    is_terminal
  )
  insert_into_buffer(target_bufnr, code_block)

  local source_label = is_terminal and 'terminal'
    or vim.fn.fnamemodify(current_file, ':t')
  vim.notify(
    string.format('Code from %s → %s', source_label, target_label),
    vim.log.levels.INFO
  )
end

-- Pin current buffer as markdown target
function M.set_markdown_target()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  if ft ~= 'markdown' then
    vim.notify(
      string.format('Cannot pin: filetype is "%s", expected "markdown"', ft),
      vim.log.levels.WARN
    )
    return
  end

  M.targets.markdown = bufnr
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
  vim.notify('Markdown target pinned: ' .. name, vim.log.levels.INFO)
end

-- Send selection to pinned markdown buffer
function M.copy_to_markdown(use_current_visual)
  if
    not M.targets.markdown or not vim.api.nvim_buf_is_valid(M.targets.markdown)
  then
    vim.notify(
      'No markdown target pinned. Use <leader>cm from a markdown buffer.',
      vim.log.levels.WARN
    )
    return
  end

  local name =
    vim.fn.fnamemodify(vim.api.nvim_buf_get_name(M.targets.markdown), ':t')
  copy_to_target(use_current_visual, M.targets.markdown, name)
end

-- Send selection to codecompanion buffer (auto-detected)
function M.copy_to_codecompanion(use_current_visual)
  local bufnr = find_codecompanion_buffer()
  if not bufnr then
    vim.notify(
      'No CodeCompanion buffer found. Open a chat first.',
      vim.log.levels.WARN
    )
    return
  end

  copy_to_target(use_current_visual, bufnr, 'CodeCompanion')
end

function M.setup()
  -- Pin current markdown buffer as the target
  vim.keymap.set('n', '<leader>cm', M.set_markdown_target, {
    desc = 'Pin current buffer as markdown target',
  })

  -- Send to pinned markdown buffer
  vim.keymap.set('v', '<leader>cc', function()
    M.copy_to_markdown(true)
  end, { desc = 'Copy selection to pinned markdown buffer' })

  vim.keymap.set('n', '<leader>cc', function()
    local line_nr = vim.api.nvim_win_get_cursor(0)[1]
    local current_line = vim.api.nvim_get_current_line()
    vim.api.nvim_buf_set_mark(0, '<', line_nr, 0, {})
    vim.api.nvim_buf_set_mark(0, '>', line_nr, #current_line, {})
    M.copy_to_markdown(false)
  end, { desc = 'Copy current line to pinned markdown buffer' })

  -- Send to codecompanion buffer
  vim.keymap.set('v', '<leader>ca', function()
    M.copy_to_codecompanion(true)
  end, { desc = 'Copy selection to CodeCompanion buffer' })

  vim.keymap.set('n', '<leader>ca', function()
    local line_nr = vim.api.nvim_win_get_cursor(0)[1]
    local current_line = vim.api.nvim_get_current_line()
    vim.api.nvim_buf_set_mark(0, '<', line_nr, 0, {})
    vim.api.nvim_buf_set_mark(0, '>', line_nr, #current_line, {})
    M.copy_to_codecompanion(false)
  end, { desc = 'Copy current line to CodeCompanion buffer' })

  -- Auto-clear pinned target if the buffer is deleted
  vim.api.nvim_create_autocmd('BufDelete', {
    callback = function(ev)
      if M.targets.markdown == ev.buf then
        M.targets.markdown = nil
        vim.notify(
          'Pinned markdown target was closed and cleared',
          vim.log.levels.WARN
        )
      end
    end,
    desc = 'Clear pinned markdown target on buffer delete',
  })
end

return M
