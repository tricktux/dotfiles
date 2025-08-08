local M = {}

-- Main function to collect tasks from daily files
function M.collect_tasks()
  local current_dir = vim.fn.getcwd()
  local cache_dir = vim.fn.stdpath('cache') .. '/dailies'

  -- Create cache directory if it doesn't exist
  vim.fn.mkdir(cache_dir, 'p')

  -- Find all daily files in current directory
  local daily_files = vim.fn.glob('????-??-??.md', false, true)

  if #daily_files == 0 then
    vim.notify('No daily files found in current directory', vim.log.levels.WARN)
    return
  end

  local collected_tasks = {}
  local processed_files = 0
  local total_tasks = 0

  -- Process each daily file
  for _, filename in ipairs(daily_files) do
    local date = filename:match('^(%d%d%d%d%-%d%d%-%d%d)%.md$')

    if date then
      local success, tasks_found =
          pcall(process_daily_file, filename, date, cache_dir, collected_tasks)
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
      'Collected %d tasks from %d files',
      total_tasks,
      processed_files
    ),
    vim.log.levels.INFO
  )
end

-- Process a single daily file
function process_daily_file(filename, date, cache_dir, collected_tasks)
  -- Read file content
  local lines = {}
  local file = io.open(filename, 'r')
  if not file then
    error('Could not read file: ' .. filename)
  end

  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()

  if #lines == 0 then
    return 0
  end

  -- Create backup
  local backup_path = cache_dir .. '/' .. filename
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

      -- Store context for this date
      if not collected_tasks[date] then
        collected_tasks[date] = {}
      end
      table.insert(collected_tasks[date], context_lines)

      -- Mark ALL tasks within the context as processed (this is the key fix)
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
    local file = io.open(filename, 'w')
    if not file then
      error('Could not write to file: ' .. filename)
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

-- Write contexts to backlog file
function write_to_backlog(collected_tasks)
  local backlog_path = 'backlog.md'

  -- Sort dates (oldest first)
  local sorted_dates = {}
  for date, _ in pairs(collected_tasks) do
    table.insert(sorted_dates, date)
  end
  table.sort(sorted_dates)

  -- Read existing backlog content
  local existing_content = {}
  local existing_dates = {}

  local backlog_file = io.open(backlog_path, 'r')
  if backlog_file then
    for line in backlog_file:lines() do
      table.insert(existing_content, line)
      -- Track existing date headers
      local date_match = line:match('^## (%d%d%d%d%-%d%d%-%d%d)$')
      if date_match then
        existing_dates[date_match] = #existing_content
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
  for _, date in ipairs(sorted_dates) do
    if existing_dates[date] then
      -- Find insertion point after existing date section
      local insert_pos = #final_content + 1
      for j = existing_dates[date] + 1, #final_content do
        if final_content[j]:match('^## %d%d%d%d%-%d%d%-%d%d$') then
          insert_pos = j
          break
        end
      end

      -- Insert tasks at the end of this date section
      for _, context in ipairs(collected_tasks[date]) do
        table.insert(final_content, insert_pos, '')
        insert_pos = insert_pos + 1
        for _, context_line in ipairs(context) do
          table.insert(final_content, insert_pos, context_line)
          insert_pos = insert_pos + 1
        end
      end
    else
      -- Add new date section at the end
      table.insert(final_content, '')
      table.insert(final_content, '## ' .. date)
      table.insert(final_content, '')
      for _, context in ipairs(collected_tasks[date]) do
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
