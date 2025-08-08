local M = {}

-- Main function to collect tasks from all markdown files in current buffer's directory
function M.collect_tasks()
  -- Get the directory of the current buffer instead of cwd
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == '' then
    vim.notify('No file in current buffer', vim.log.levels.WARN)
    return
  end

  local current_dir = vim.fn.fnamemodify(current_file, ':h')
  local cache_dir = vim.fs.joinpath(vim.fn.stdpath('cache'), 'dailies')

  -- Create cache directory if it doesn't exist
  vim.fn.mkdir(cache_dir, 'p')

  -- Get today's date to exclude it
  local today = os.date('%Y-%m-%d') .. '.md'

  -- Find all .md files in current buffer's directory
  -- Use vim.fn.glob with proper path joining for cross-platform compatibility
  local glob_pattern = vim.fs.joinpath(current_dir, '*.md')
  local all_files = vim.fn.glob(glob_pattern, false, true)

  local files_to_process = {}

  for _, filepath in ipairs(all_files) do
    local filename = vim.fn.fnamemodify(filepath, ':t')
    if filename ~= today and filename ~= 'backlog.md' then
      table.insert(files_to_process, filepath)
    end
  end

  if #files_to_process == 0 then
    vim.notify(
      'No files to process in current directory (excluding today)',
      vim.log.levels.WARN
    )
    return
  end

  local collected_tasks = {}
  local processed_files = 0
  local total_tasks = 0

  -- Process each file
  for _, filepath in ipairs(files_to_process) do
    local filename = vim.fn.fnamemodify(filepath, ':t')
    -- Try to extract date from filename, otherwise use filename without extension
    local file_key = filename:match('^(%d%d%d%d%-%d%d%-%d%d)%.md$')
        or filename:match('^(.+)%.md$')
        or filename

    local success, tasks_found =
        pcall(process_file, filepath, file_key, cache_dir, collected_tasks)
    if not success then
      vim.notify(
        'Error processing ' .. filename .. ': ' .. tasks_found,
        vim.log.levels.ERROR
      )
      return
    end

    if tasks_found > 0 then
      processed_files = processed_files + 1
      total_tasks = total_tasks + tasks_found
    end
  end

  -- Write to backlog if we found tasks
  if total_tasks > 0 then
    local success, err = pcall(write_to_backlog, collected_tasks)
    if not success then
      vim.notify('Error writing to backlog: ' .. err, vim.log.levels.ERROR)
      return
    end
  end

  -- Show summary
  vim.notify(
    string.format(
      'Collected %d tasks from %d files in %s (excluding today)',
      total_tasks,
      processed_files,
      vim.fn.fnamemodify(current_dir, ':t')
    ),
    vim.log.levels.INFO
  )
end

-- Process a single file (updated to handle full file paths)
function process_file(filepath, file_key, cache_dir, collected_tasks)
  -- Read file content
  local lines = {}
  local file = io.open(filepath, 'r')
  if not file then
    error('Could not read file: ' .. filepath)
  end

  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()

  if #lines == 0 then
    return 0
  end

  -- Create backup using proper path joining
  local filename = vim.fn.fnamemodify(filepath, ':t')
  local backup_path = vim.fs.joinpath(cache_dir, filename)
  local backup_file = io.open(backup_path, 'w')
  if not backup_file then
    error('Could not create backup file: ' .. backup_path)
  end

  for _, line in ipairs(lines) do
    backup_file:write(line .. '\n')
  end
  backup_file:close()

  -- Find and process tasks
  local modified = false
  local tasks_found = 0

  for i, line in ipairs(lines) do
    -- Check for uncompleted task with empty brackets only
    if line:match('%- %[ %]') then
      tasks_found = tasks_found + 1

      -- Extract context
      local context_start = find_context_start(lines, i)
      local context_end = find_context_end(lines, i)

      -- Extract context lines
      local context_lines = {}
      for j = context_start, context_end do
        table.insert(context_lines, lines[j])
      end

      -- Store context for this file_key
      if not collected_tasks[file_key] then
        collected_tasks[file_key] = {}
      end
      table.insert(collected_tasks[file_key], context_lines)

      -- Mark ALL tasks within the context as processed
      for j = context_start, context_end do
        if lines[j]:match('%- %[ %]') then
          lines[j] = lines[j]:gsub('%- %[ %]', '- [>]')
          modified = true
        end
      end
    end
  end

  -- Write modified file if we found tasks
  if modified then
    local file = io.open(filepath, 'w')
    if not file then
      error('Could not write to file: ' .. filepath)
    end

    for _, line in ipairs(lines) do
      file:write(line .. '\n')
    end
    file:close()
  end

  return tasks_found
end

-- Find the start of context (walk up to 0 indentation or start of file)
function find_context_start(lines, task_line)
  for i = task_line, 1, -1 do
    local line = lines[i]
    -- Check if line is not empty/whitespace and starts at column 1
    if line:match('^%S') then
      return i
    end
  end
  return 1 -- Start of file
end

-- Find the end of context (walk down to 0 indentation, not inclusive, or end of file)
function find_context_end(lines, task_line)
  for i = task_line + 1, #lines do
    local line = lines[i]
    -- Check if line is not empty/whitespace and starts at column 1
    if line:match('^%S') then
      return i - 1 -- Not inclusive
    end
  end
  return #lines -- End of file
end

-- Write contexts to backlog file (updated to handle non-date keys)
function write_to_backlog(collected_tasks)
  -- Get backlog path in the same directory as current buffer
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = vim.fn.fnamemodify(current_file, ':h')
  local backlog_path = vim.fs.joinpath(current_dir, 'backlog.md')

  -- Sort keys (dates first, then alphabetical for other files)
  local sorted_keys = {}
  for key, _ in pairs(collected_tasks) do
    table.insert(sorted_keys, key)
  end

  table.sort(sorted_keys, function(a, b)
    local a_is_date = a:match('^%d%d%d%d%-%d%d%-%d%d$')
    local b_is_date = b:match('^%d%d%d%d%-%d%d%-%d%d$')

    if a_is_date and b_is_date then
      return a < b -- Sort dates chronologically
    elseif a_is_date and not b_is_date then
      return true  -- Dates come first
    elseif not a_is_date and b_is_date then
      return false -- Dates come first
    else
      return a < b -- Sort non-dates alphabetically
    end
  end)

  -- Read existing backlog content
  local existing_content = {}
  local existing_keys = {}

  local backlog_file = io.open(backlog_path, 'r')
  if backlog_file then
    for line in backlog_file:lines() do
      table.insert(existing_content, line)
      -- Track existing headers (both date and non-date)
      local key_match = line:match('^## (.+)$')
      if key_match then
        existing_keys[key_match] = #existing_content
      end
    end
    backlog_file:close()
  end

  -- Prepare final content
  local final_content = {}

  if #existing_content == 0 then
    -- Create new backlog file
    table.insert(final_content, '# Task Backlog')
    table.insert(final_content, '')
  else
    -- Copy existing content
    for _, line in ipairs(existing_content) do
      table.insert(final_content, line)
    end
  end

  -- Add new tasks
  for _, key in ipairs(sorted_keys) do
    if existing_keys[key] then
      -- Find insertion point after existing section
      local insert_pos = #final_content + 1
      for j = existing_keys[key] + 1, #final_content do
        if final_content[j]:match('^## .+$') then
          insert_pos = j
          break
        end
      end

      -- Insert tasks at the end of this section
      for _, context in ipairs(collected_tasks[key]) do
        table.insert(final_content, insert_pos, '')
        insert_pos = insert_pos + 1
        for _, context_line in ipairs(context) do
          table.insert(final_content, insert_pos, context_line)
          insert_pos = insert_pos + 1
        end
      end
    else
      -- Add new section at the end
      table.insert(final_content, '')
      table.insert(final_content, '## ' .. key)
      table.insert(final_content, '')
      for _, context in ipairs(collected_tasks[key]) do
        for _, context_line in ipairs(context) do
          table.insert(final_content, context_line)
        end
      end
    end
  end

  -- Write final content
  local file = io.open(backlog_path, 'w')
  if not file then
    error('Could not write to backlog file: ' .. backlog_path)
  end

  for _, line in ipairs(final_content) do
    file:write(line .. '\n')
  end
  file:close()
end

return M
