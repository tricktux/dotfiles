local M = {}

-- Function to get visual selection using current visual mode
local function get_current_visual_selection()
  local start_pos = vim.fn.getpos('v') -- Start of visual selection
  local end_pos = vim.fn.getcurpos()   -- Current cursor position

  -- Make sure start is before end
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

-- Function to get visual selection from marks (for when not in visual mode)
local function get_visual_selection_from_marks()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  return lines, start_line
end

-- Function to find most recently visited markdown buffer in current tab
local function find_recent_markdown_buffer()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local tab_wins = vim.api.nvim_tabpage_list_wins(current_tab)

  local markdown_buffers = {}

  -- Collect all markdown buffers visible in current tab
  for _, winid in ipairs(tab_wins) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    if
        vim.api.nvim_buf_is_valid(bufnr)
        and vim.bo[bufnr].filetype == 'markdown'
        and vim.api.nvim_buf_get_name(bufnr) ~= ''
    then
      table.insert(markdown_buffers, bufnr)
    end
  end

  if #markdown_buffers == 0 then
    return nil
  end

  if #markdown_buffers == 1 then
    return markdown_buffers[1]
  end

  -- Find most recently accessed
  local most_recent = markdown_buffers[1]
  local most_recent_time = vim.fn.getbufinfo(most_recent)[1].lastused

  for i = 2, #markdown_buffers do
    local buf = markdown_buffers[i]
    local buf_info = vim.fn.getbufinfo(buf)[1]
    if buf_info.lastused > most_recent_time then
      most_recent = buf
      most_recent_time = buf_info.lastused
    end
  end

  return most_recent
end

-- Function to check if buffer is a terminal
local function is_terminal_buffer(bufnr)
  bufnr = bufnr or 0
  return vim.bo[bufnr].buftype == 'terminal'
end

-- Function to detect language from filetype
local function get_language_from_filetype(filetype, is_terminal)
  if is_terminal then
    return 'shell' -- or 'bash', 'terminal', whatever you prefer
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

-- Function to get comment prefix from commentstring
local function get_comment_prefix()
  local commentstring = vim.bo.commentstring
  if not commentstring or commentstring == '' then
    return '#' -- fallback
  end

  -- Extract comment prefix (part before %s)
  local comment_prefix = commentstring:match('^(.-)%%s')
  if comment_prefix then
    -- Remove trailing spaces
    comment_prefix = comment_prefix:gsub('%s+$', '')
    return comment_prefix
  end

  -- If no %s found, use the whole commentstring (trimmed)
  return commentstring:gsub('%s+$', '')
end

-- Main function to copy code to markdown
function M.copy_code_to_markdown(use_current_visual)
  local selected_lines, start_line

  -- Get selection based on whether we're in visual mode or not
  if use_current_visual then
    selected_lines, start_line = get_current_visual_selection()
  else
    selected_lines, start_line = get_visual_selection_from_marks()
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local is_terminal = is_terminal_buffer(0)

  -- For terminal buffers, we don't need a file path
  if not is_terminal and current_file == '' then
    print('Current buffer has no file path')
    return
  end

  if #selected_lines == 0 then
    print('No text selected')
    return
  end

  -- Find target markdown buffer
  local markdown_bufnr = find_recent_markdown_buffer()
  if not markdown_bufnr then
    print('No markdown buffer found in current tab')
    return
  end

  -- Format code block
  local language = get_language_from_filetype(filetype, is_terminal)
  local code_block = { '```' .. language }

  -- Add file reference comment only for non-terminal buffers
  if not is_terminal then
    local comment_prefix = get_comment_prefix()
    local file_reference = string.format('%s:%d', current_file, start_line)
    table.insert(code_block, comment_prefix .. ' ' .. file_reference)
  end

  -- Add each selected line individually
  for _, line in ipairs(selected_lines) do
    table.insert(code_block, line)
  end

  -- Add closing and spacing
  table.insert(code_block, '```')
  table.insert(code_block, '') -- Empty line after code block for spacing

  -- Find the window showing the markdown buffer
  local markdown_win = nil
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(winid) == markdown_bufnr then
      markdown_win = winid
      break
    end
  end

  if not markdown_win then
    print('Markdown buffer is not visible in current tab')
    return
  end

  -- Get cursor position in markdown buffer
  local cursor_pos = vim.api.nvim_win_get_cursor(markdown_win)
  local insert_line = cursor_pos[1]

  -- Insert code block
  vim.api.nvim_buf_set_lines(
    markdown_bufnr,
    insert_line,
    insert_line,
    false,
    code_block
  )

  -- Switch to markdown buffer and position cursor after the code block
  vim.api.nvim_set_current_win(markdown_win)
  vim.api.nvim_win_set_cursor(markdown_win, { insert_line + #code_block, 0 })

  local filename =
      vim.fn.fnamemodify(vim.api.nvim_buf_get_name(markdown_bufnr), ':t')
  local source_type = is_terminal and 'terminal' or 'file'
  print(
    string.format('Code snippet copied from %s to %s', source_type, filename)
  )
end

function M.setup()
  -- Visual mode mapping - capture selection while in visual mode
  vim.keymap.set('v', '<leader>cc', function()
    M.copy_code_to_markdown(true) -- Use current visual selection
  end, { desc = 'Copy code selection to markdown' })

  -- Normal mode mapping for current line
  vim.keymap.set('n', '<leader>cc', function()
    -- Get current line info and set up marks
    local current_line = vim.api.nvim_get_current_line()
    local line_nr = vim.api.nvim_win_get_cursor(0)[1]

    -- Set visual marks for current line
    vim.api.nvim_buf_set_mark(0, '<', line_nr, 0, {})
    vim.api.nvim_buf_set_mark(0, '>', line_nr, #current_line, {})

    M.copy_code_to_markdown(false) -- Use marks
  end, { desc = 'Copy current line to markdown' })
end

return M
