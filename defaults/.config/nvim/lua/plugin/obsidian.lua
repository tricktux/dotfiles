local utl = require('utils.utils')

local M = {}

-- Parse calendar output into structured data
local function parse_calendar_output(output)
  local events = {}
  local today = os.date('%Y-%m-%d')
  local tomorrow = os.date('%Y-%m-%d', os.time() + 24 * 60 * 60)

  for line in output:gmatch('[^\r\n]+') do
    local date, time, title =
        line:match('(%d%d%d%d%-%d%d%-%d%d) (%d%d:%d%d) (.+)')
    if date and time and title then
      local day_label
      if date == today then
        day_label = 'Today'
      elseif date == tomorrow then
        day_label = 'Tomorrow'
      else
        -- Convert to day name (Mon, Tue, etc.)
        local timestamp = os.time({
          year = tonumber(date:sub(1, 4)),
          month = tonumber(date:sub(6, 7)),
          day = tonumber(date:sub(9, 10)),
        })
        day_label = os.date('%A', timestamp) -- Full day name
      end

      if not events[day_label] then
        events[day_label] = {}
      end
      table.insert(events[day_label], {
        time = time,
        title = title,
      })
    end
  end

  return events
end

-- Parse todo output into structured data
local function parse_todo_output(output)
  local overdue = {}
  local due_this_week = {}

  for line in output:gmatch('[^\r\n]+') do
    if line:match('^%[%s*%]') then -- Lines starting with [ ]
      local is_overdue = line:match('yesterday')
          or line:match('in %d+ hours')
          or line:match('today')

      if is_overdue then
        table.insert(overdue, '- ' .. line)
      else
        table.insert(due_this_week, '- ' .. line)
      end
    end
  end

  return overdue, due_this_week
end

-- Format calendar data as markdown
local function format_calendar_markdown(events)
  local lines = { "# 📅 This Week's Calendar", '' }

  -- Order: Today, Tomorrow, then other days
  local day_order = {
    'Today',
    'Tomorrow',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  }

  for _, day in ipairs(day_order) do
    if events[day] and #events[day] > 0 then
      table.insert(lines, '## ' .. day)
      table.insert(lines, '')
      for _, event in ipairs(events[day]) do
        table.insert(lines, '- ' .. event.time .. ' ' .. event.title)
      end
      table.insert(lines, '')
    end
  end

  return table.concat(lines, '\n')
end

-- Format todo data as markdown
local function format_todos_markdown(overdue, due_this_week)
  local lines = { '# ✅ Tasks & Todos', '' }

  if #overdue > 0 then
    table.insert(lines, '## Overdue')
    table.insert(lines, '')
    for _, todo in ipairs(overdue) do
      table.insert(lines, todo)
    end
    table.insert(lines, '')
  end

  if #due_this_week > 0 then
    table.insert(lines, '## Due This Week')
    table.insert(lines, '')
    for _, todo in ipairs(due_this_week) do
      table.insert(lines, todo)
    end
    table.insert(lines, '')
  end

  return table.concat(lines, '\n')
end

-- Find and replace a section in markdown content
local function replace_markdown_section(content, section_header, new_content)
  local pattern = '(# '
      .. section_header:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1')
      .. '.-\n)(.-)(^#[^#])'
  local before_section = content:match('^(.-)' .. pattern)
  local after_section = content:match(pattern .. '(.*)$')

  if before_section and after_section then
    return before_section .. new_content .. '\n' .. after_section
  else
    -- If section not found, append at end
    return content .. '\n' .. new_content
  end
end

-- Main refresh function
function M.refresh_daily_data()
  if vim.fn.executable('vdirsyncer') == 0 then
    print('vdirsyncer is not installed or not executable')
    return
  end

  if vim.fn.executable('khal') == 0 then
    print('khal is not installed or not executable')
    return
  end

  if vim.fn.executable('todo') == 0 then
    print('todo is not installed or not executable')
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local content =
      table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')

  -- Sync calendars
  local sync_cmd = 'vdirsyncer sync'
  local sync_output = vim.fn.system(sync_cmd)

  -- Fetch calendar data
  local calendar_cmd =
  "khal list --format '{start-date-long} {start-time} {title}' --day-format '' today 7d"
  local calendar_output = vim.fn.system(calendar_cmd)
  local events = parse_calendar_output(calendar_output)
  local calendar_markdown = format_calendar_markdown(events)

  -- Fetch overdue todo data
  local todo_cmd = 'todo list --sort -due,priority --due=-24'
  local overdue = vim.fn.system(todo_cmd)

  -- Fetch todo data
  todo_cmd = 'todo list --sort -due,priority --due 72'
  local due_this_week = vim.fn.system(todo_cmd)

  todos_markdown = format_todos_markdown(overdue, due_this_week)

  -- Replace sections
  content = replace_markdown_section(
    content,
    "📅 This Week's Calendar",
    calendar_markdown
  )
  content =
      replace_markdown_section(content, '✅ Tasks & Todos', todos_markdown)

  -- Update buffer
  local lines = vim.split(content, '\n')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  print('Daily data refreshed!')
end

-- Get the obsidian client
local function get_obsidian_client()
  return require('obsidian').get_client()
end

-- Sanitize name and create ID
local function sanitize_name(name)
  if not name or name == '' then
    return nil, nil
  end

  -- Clean the display name (trim whitespace)
  local clean_name = name:match('^%s*(.-)%s*$')

  -- Create ID (lowercase, alphanumeric + hyphens/underscores only)
  local id = clean_name
      :lower()
      :gsub('[^%w%-_]', '-')
      :gsub('%-+', '-')
      :gsub('^%-+', '')
      :gsub('%-+$', '')

  return clean_name, id
end

-- Get list of project directories
local function get_projects()
  local client = get_obsidian_client()
  local projects_path = vim.fs.joinpath(client.dir.filename, 'projects')

  -- Check if projects directory exists
  if vim.fn.isdirectory(projects_path) == 0 then
    print('Projects directory does not exist: ' .. projects_path)
    return {}
  end

  local projects = {}
  -- Use vim.fs.dir to iterate over directory contents
  for name, type in vim.fs.dir(projects_path) do
    if type == 'directory' then
      table.insert(projects, name)
    end
  end

  return projects
end

-- Get the appropriate daily template for a project
local function get_daily_template(project_name)
  local client = get_obsidian_client()
  local project_template = 'project-daily-' .. project_name

  -- Check if project-specific template exists
  local templates_path = vim.fs.joinpath(client.dir.filename, 'templates')
  local project_template_file =
      vim.fs.joinpath(templates_path, project_template .. '.md')

  if utl.isfile(project_template_file) == true then
    return project_template
  else
    return 'project-daily' -- fallback to default
  end
end

-- Create a new project from template
function M.create_project()
  vim.ui.input({ prompt = 'Project name: ' }, function(input_name)
    local clean_name, id = sanitize_name(input_name)

    if not clean_name then
      return
    end

    local client = get_obsidian_client()

    -- Create the main project note
    local project_note = client:create_note({
      title = clean_name,
      id = id,
      dir = vim.fs.joinpath('projects', id),
      template = 'project-template',
    })

    if project_note then
      -- Open the new project note
      client:open_note(project_note)
      print('Created project: ' .. id)
    else
      print('Error creating project')
    end
  end)
end

-- Create a project with additional files
function M.create_project_full()
  vim.ui.input({ prompt = 'Project name: ' }, function(input_name)
    local clean_name, id = sanitize_name(input_name)

    if not clean_name then
      return
    end

    local client = get_obsidian_client()

    -- Create main project note. Directories will be created by obsidian
    local project_note = client:create_note({
      title = clean_name,
      id = id,
      dir = vim.fs.joinpath('projects', id),
      template = 'project-template',
    })

    -- Create additional project files
    local additional_files = {
      { title = 'Presentation', template = 'project-presentation' },
      -- { title = 'Notes',     template = 'project-notes' },
      -- { title = 'Resources', template = 'project-resources' },
    }

    for _, file in ipairs(additional_files) do
      client:create_note({
        title = clean_name .. ' ' .. file.title,
        id = id .. '-' .. string.lower(file.title),
        dir = vim.fs.joinpath('projects', id),
        template = file.template,
      })
    end

    -- Copy makefile if it exists
    local make_name = 'make.sh'
    local make_file =
        vim.fs.joinpath(client.dir.filename, 'templates', make_name)
    local make_dst =
        vim.fs.joinpath(client.dir.filename, 'projects', id, make_name)
    if utl.isfile(make_file) == true then
      local _, err = vim.uv.fs_copyfile(make_file, make_dst)
      if err ~= nil then
        print(
          "Failed to copy make_file: '"
          .. make_file
          .. "' to: '"
          .. make_dst
          .. "'"
        )
      end
    end

    if project_note then
      client:open_note(project_note)
      print('Created project with structure: ' .. clean_name)
    else
      print('Error creating project')
    end
  end)
end

-- Quick access to today's daily notes across all projects (cross-platform)
function M.find_daily_notes()
  local client = get_obsidian_client()
  local builtin = require('telescope.builtin')
  local date_suffix = os.date('%Y-%m-%d')
  local projects_path = vim.fs.joinpath(client.dir.filename, 'projects')

  -- Find all daily notes for today using vim.fs.find
  local daily_files = vim.fs.find(function(name, type)
    return type == 'file' and name:match(date_suffix .. '%.md$')
  end, {
    path = projects_path,
    type = 'file',
  })

  if #daily_files == 0 then
    print('No daily notes found for today')
    return
  end

  builtin.find_files({
    prompt_title = "Today's Daily Notes",
    search_dirs = { projects_path },
    find_command = vim.tbl_flatten({
      'rg',
      '--files',
      '--glob',
      '*' .. date_suffix .. '.md',
    }),
  })
end

-- Fuzzy search all projects (cross-platform)
function M.find_projects()
  local client = get_obsidian_client()
  local builtin = require('telescope.builtin')

  builtin.find_files({
    prompt_title = 'Find Projects',
    search_dirs = { vim.fs.joinpath(client.dir.filename, 'projects') },
    find_command = { 'rg', '--files', '--glob', '*.md' },
  })
end

-- Rest of the functions remain the same...
function M.project_daily()
  local projects = get_projects()

  if #projects == 0 then
    print('No projects found. Create a project first.')
    return
  end

  -- Use telescope for consistent UI
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers
      .new({}, {
        prompt_title = 'Select Project for Daily Note',
        finder = finders.new_table({
          results = projects,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              local project_name = selection[1]
              local client = get_obsidian_client()
              local date_suffix = os.date('%Y-%m-%d')
              local daily_title = project_name

              -- Check if daily note already exists
              local daily_path =
                  vim.fs.joinpath('projects', project_name, date_suffix .. '.md')
              local vault_path = client.dir.filename
              local full_path = vim.fs.joinpath(vault_path, daily_path)

              if utl.isfile(full_path) == true then
                -- Open existing daily note
                vim.cmd('edit ' .. full_path)
                print('Opened existing daily note for ' .. project_name)
              else
                -- Create new daily note
                local daily_note = client:create_note({
                  title = daily_title,
                  id = date_suffix,
                  dir = vim.fs.joinpath('projects/', project_name),
                  template = get_daily_template(project_name),
                })

                if daily_note then
                  client:open_note(daily_note)
                  print('Created daily note for ' .. project_name)
                else
                  print('Error creating daily note')
                end
              end
            end
          end)
          return true
        end,
      })
      :find()
end

-- List project directories and open main project file
function M.list_projects()
  local client = get_obsidian_client()
  local projects_path = vim.fs.joinpath(client.dir.filename, 'projects')
  local projects = get_projects()

  if #projects == 0 then
    print('No projects found.')
    return
  end

  -- Use telescope to select project
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers
      .new({}, {
        prompt_title = 'Select Project',
        finder = finders.new_table({
          results = projects,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              -- Open main project file
              local project_file = vim.fs.joinpath(
                projects_path,
                selection[1],
                selection[1] .. '.md'
              )
              if utl.isfile(project_file) == true then
                vim.cmd('edit ' .. project_file)
              else
                print('Project file not found: ' .. project_file)
              end
            end
          end)
          return true
        end,
      })
      :find()
end

-- Define the highlight group
local function setup_highlight()
  local bg = vim.o.background
  if bg == 'light' then
    vim.api.nvim_set_hl(0, 'ObsidianTag', {
      fg = '#0f766e', -- teal-700 for light
      bold = true,
    })
  else
    vim.api.nvim_set_hl(0, 'ObsidianTag', {
      fg = '#2dd4bf', -- teal-400 for dark
      bold = true,
    })
  end
end

-- Set up the highlight initially and on colorscheme changes
setup_highlight()
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = setup_highlight,
})

-- Function to highlight Obsidian tags using extmarks
local function highlight_obsidian_tags(bufnr)
  local ns = vim.api.nvim_create_namespace('obsidian_tags')
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for line_nr, line in ipairs(lines) do
    local col = 1
    while col <= #line do
      local start_col, end_col = string.find(line, '#[%w_/-]+', col)
      if start_col then
        vim.api.nvim_buf_set_extmark(bufnr, ns, line_nr - 1, start_col - 1, {
          end_col = end_col,
          hl_group = 'ObsidianTag',
        })
        col = end_col + 1
      else
        break
      end
    end
  end
end

function M.setup()
  vim.keymap.set('n', '<leader>wpc', function()
    M.create_project()
  end, { desc = 'Create new project' })
  vim.keymap.set('n', '<leader>wpf', function()
    M.create_project_full()
  end, { desc = 'Create project with full structure' })
  vim.keymap.set('n', '<leader>wpp', function()
    M.list_projects()
  end, { desc = 'List projects' })
  vim.keymap.set('n', '<leader>wps', function()
    M.find_projects()
  end, { desc = 'Search projects' })
  vim.keymap.set('n', '<leader>wpd', function()
    M.project_daily()
  end, { desc = 'Create/open project daily note' })
  vim.keymap.set('n', '<leader>wpt', function()
    M.find_daily_notes()
  end, { desc = "Find today's daily notes" })
  vim.keymap.set('n', '<leader>wpr', function()
    M.refresh_daily_data()
  end, { desc = 'Refresh daily calendar and todos' })

  -- Set up autocmds for markdown files
  vim.api.nvim_create_autocmd(
    { 'BufEnter', 'BufWritePost', 'TextChanged', 'TextChangedI' },
    {
      pattern = '*.md',
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].filetype == 'markdown' then
          highlight_obsidian_tags(bufnr)
        end
      end,
    }
  )
end

return M
