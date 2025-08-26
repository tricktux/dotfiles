local utl = require('utils.utils')
local log = require('utils.log')

local M = {}

-- Extract project name from path or context (updated for nested projects)
function M.get_project_name_from_context(ctx)
  local function extract_project_path(path_str)
    -- Normalize path separators for cross-platform compatibility
    local normalized = path_str:gsub('\\', '/')

    -- Try to match nested project paths (deepest first)
    local match = normalized:match('/projects/([^/]+/[^/]+/[^/]+)/')
        or normalized:match('/projects/([^/]+/[^/]+)/')
        or normalized:match('/projects/([^/]+)/')
    return match
  end

  if ctx.type == 'clone_template' and ctx.destination_path then
    local path_str = tostring(ctx.destination_path)
    return extract_project_path(path_str)
  elseif ctx.type == 'insert_template' then
    local current_file = vim.api.nvim_buf_get_name(0)
    return extract_project_path(current_file)
  end
  return ''
end

-- Find the most recent project daily note in a specific project directory
-- Find the most recent project daily note in a specific project directory
function M.find_last_daily_note(path, include_today)
  if vim.fn.isdirectory(path) == 0 then
    return ''
  end

  local daily_files = {}
  local today = os.date('%Y-%m-%d') .. '.md'
  local should_include_today = include_today == true

  for name, type in vim.fs.dir(path) do
    if type == 'file' and name:match('%d%d%d%d%-%d%d%-%d%d%.md$') then
      -- Simple comparison instead of pattern matching
      if should_include_today or name ~= today then
        table.insert(daily_files, name)
      end
    end
  end

  if #daily_files == 0 then
    return ''
  end

  -- Sort by date (filename) in descending order
  table.sort(daily_files, function(a, b)
    return a > b
  end)

  -- Return the most recent one (first after sorting)
  local last_file = daily_files[1]

  -- Add safety check in case of unexpected nil
  if not last_file then
    return ''
  end

  local date = last_file:match('(%d%d%d%d%-%d%d%-%d%d)%.md$')
  return date or ''
end

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
local function format_todos_markdown(todos)
  local lines = { '# ✅ Tasks & Todos', '' }

  if #todos > 0 then
    table.insert(lines, '## Due This Week')
    table.insert(lines, '')
    for _, todo in ipairs(todos) do
      table.insert(lines, '- ' .. todo)
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
  if vim.v.shell_error ~= 0 then
    print('Error syncing calendars: ' .. sync_output)
    return
  end

  -- Fetch calendar data
  local calendar_cmd =
  "khal list --format '{start-date-long} {start-time} {title}' --day-format '' today 7d"
  local calendar_output = vim.fn.system(calendar_cmd)
  if vim.v.shell_error ~= 0 then
    print('Error fetching calendar data: ' .. calendar_output)
    return
  end
  local events = parse_calendar_output(calendar_output)
  local calendar_markdown = format_calendar_markdown(events)

  -- Fetch todo data
  local todo_cmd = 'todo list --sort -due,priority --due 72'
  local todos = vim.fn.systemlist(todo_cmd)
  if vim.v.shell_error ~= 0 then
    print('Error fetching todo data: ' .. table.concat(todos, '\n'))
    return
  end

  todos_markdown = format_todos_markdown(todos)

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

-- Get list of project directories (updated for nested projects)
local function get_projects()
  local projects_path = vim.fs.joinpath(Obsidian.dir.filename, 'projects')

  -- Check if projects directory exists
  if vim.fn.isdirectory(projects_path) == 0 then
    print('Projects directory does not exist: ' .. projects_path)
    return {}
  end

  local projects = {}

  -- Recursive function to find projects with depth limit
  local function find_projects_recursive(path, relative_path, depth)
    if depth > 3 then
      return
    end -- Max 3 levels

    for name, type in vim.fs.dir(path) do
      if type == 'directory' then
        local current_path = vim.fs.joinpath(path, name)
        local current_relative = relative_path
            and (relative_path .. '/' .. name)
            or name

        -- Check if this directory contains a project file
        local project_file_name = current_relative:gsub('/', '-') .. '.md'
        local project_file_path =
            vim.fs.joinpath(current_path, project_file_name)

        if utl.isfile(project_file_path) then
          table.insert(projects, current_relative)
        end

        -- Recurse into subdirectories
        find_projects_recursive(current_path, current_relative, depth + 1)
      end
    end
  end

  find_projects_recursive(projects_path, nil, 1)

  return projects
end

-- Convert project path to tags (e.g., "parent1/child1/child2" -> {"projects", "parent1", "child1", "child2"})
local function project_path_to_tags(project_path)
  local tags = { 'projects' }
  for part in project_path:gmatch('[^/]+') do
    table.insert(tags, part)
  end
  return tags
end

-- Get the appropriate daily template for a project
local function get_daily_template(project_path)
  local project_parts = vim.split(project_path, '/')
  local project_name = project_parts[#project_parts] -- Get leaf name
  local project_template = 'project-daily-' .. project_name

  -- Check if project-specific template exists
  local templates_path = vim.fs.joinpath(Obsidian.dir.filename, 'templates')
  local project_template_file =
      vim.fs.joinpath(templates_path, project_template .. '.md')

  if utl.isfile(project_template_file) == true then
    return project_template
  else
    return 'project-daily' -- fallback to default
  end
end

-- Create a project with additional files (updated for nested projects)
function M.create_project(full)
  vim.ui.input({ prompt = 'Project name: ' }, function(input_name)
    local clean_name, id = sanitize_name(input_name)

    if not clean_name then
      return
    end

    local note = require 'obsidian.note'

    -- Create main project note. Directories will be created by obsidian
    local project_note = note.create({
      title = clean_name,
      id = id,
      dir = vim.fs.joinpath('projects', id),
      template = 'project-template',
      tags = { 'projects', id },
      should_write = true,
    })

    if full == true then
      -- Create additional project files
      local additional_files = {
        { title = 'Presentation', template = 'project-presentation' },
        -- { title = 'Notes',     template = 'project-notes' },
        -- { title = 'Resources', template = 'project-resources' },
      }

      for _, file in ipairs(additional_files) do
        local type = string.lower(file.title)
        note.create({
          title = clean_name .. ' ' .. file.title,
          id = id .. '-' .. type,
          tags = { 'projects', id, type },
          dir = vim.fs.joinpath('projects', id),
          template = file.template,
          should_write = true,
        })
      end

      -- Copy makefile if it exists
      local make_name = 'make.sh'
      local make_file =
          vim.fs.joinpath(Obsidian.dir.filename, 'templates', make_name)
      local make_dst =
          vim.fs.joinpath(Obsidian.dir.filename, 'projects', id, make_name)
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
    end

    if project_note then
      note.open(project_note)
      print('Created project: ' .. clean_name)
    else
      print('Error creating project')
    end
  end)
end

-- Create a nested project with parent selection
function M.create_nested_project(full)
  local projects = get_projects()

  if #projects == 0 then
    print('No existing projects found. Create a top-level project first.')
    return
  end

  -- Filter projects that aren't at max depth (3 levels)
  local available_parents = {}
  for _, project_path in ipairs(projects) do
    local depth = select(2, project_path:gsub('/', ''))
    if depth < 2 then -- Can add children if depth < 2 (so max final depth is 3)
      table.insert(available_parents, project_path)
    end
  end

  if #available_parents == 0 then
    print('No projects available for nesting (max depth reached)')
    return
  end

  -- Use telescope to select parent project
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers
      .new({}, {
        prompt_title = 'Select Parent Project',
        finder = finders.new_table({
          results = available_parents,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry:gsub('/', ' → '), -- Show hierarchy with arrows
              ordinal = entry,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              local parent_path = selection.value

              -- Get child project name
              vim.ui.input(
                { prompt = 'Child project name: ' },
                function(input_name)
                  local clean_name, id = sanitize_name(input_name)

                  if not clean_name then
                    return
                  end

                  local note = require 'obsidian.note'
                  local child_path = parent_path .. '/' .. id
                  local verbose_id = child_path:gsub('/', '-')

                  -- Create main nested project note
                  local project_note = note.create({
                    title = clean_name,
                    id = verbose_id,
                    dir = vim.fs.joinpath('projects', child_path),
                    template = 'project-template',
                    tags = project_path_to_tags(child_path),
                    should_write = true,
                  })

                  if full == true then
                    -- Create additional project files
                    local additional_files = {
                      {
                        title = 'Presentation',
                        template = 'project-presentation',
                      },
                    }

                    for _, file in ipairs(additional_files) do
                      local type = string.lower(file.title)
                      note.create({
                        title = clean_name .. ' ' .. file.title,
                        id = verbose_id .. '-' .. type,
                        tags = vim.tbl_extend(
                          'force',
                          project_path_to_tags(child_path),
                          { type }
                        ),
                        dir = vim.fs.joinpath('projects', child_path),
                        template = file.template,
                        should_write = true,
                      })
                    end

                    -- Copy makefile if it exists
                    local make_name = 'make.sh'
                    local make_file = vim.fs.joinpath(
                      Obsidian.dir.filename,
                      'templates',
                      make_name
                    )
                    local make_dst = vim.fs.joinpath(
                      Obsidian.dir.filename,
                      'projects',
                      child_path,
                      make_name
                    )
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
                  end

                  if project_note then
                    note.open(project_note)
                    print(
                      'Created nested project: '
                      .. parent_path
                      .. ' → '
                      .. clean_name
                    )
                  else
                    print('Error creating nested project')
                  end
                end
              )
            end
          end)
          return true
        end,
      })
      :find()
end

-- Quick access to today's daily notes across all projects (updated for nested projects)
function M.find_daily_notes()
  local builtin = require('telescope.builtin')
  local date_suffix = os.date('%Y-%m-%d')
  local projects_path = vim.fs.joinpath(Obsidian.dir.filename, 'projects')

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

-- Fuzzy search all projects (updated for nested projects)
function M.find_projects()
  local builtin = require('telescope.builtin')

  builtin.find_files({
    prompt_title = 'Find Projects',
    search_dirs = { vim.fs.joinpath(Obsidian.dir.filename, 'projects') },
    find_command = { 'rg', '--files', '--glob', '*.md' },
  })
end

-- Create/open project daily note (updated for nested projects)
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
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry:gsub('/', ' → '), -- Show hierarchy with arrows
              ordinal = entry,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              local note = require 'obsidian.note'
              local project_path = selection.value
              local project_parts = vim.split(project_path, '/')
              local project_name = project_parts[#project_parts] -- Get leaf name
              local date_suffix = os.date('%Y-%m-%d')
              local daily_title = project_name

              -- Check if daily note already exists
              local daily_path =
                  vim.fs.joinpath('projects', project_path, date_suffix .. '.md')
              local vault_path = Obsidian.dir.filename
              local full_path = vim.fs.joinpath(vault_path, daily_path)

              if utl.isfile(full_path) == true then
                -- Open existing daily note
                vim.cmd('edit ' .. full_path)
                print(
                  'Opened existing daily note for '
                  .. project_path:gsub('/', ' → ')
                )
              else
                -- Create new daily note
                local tn = {
                  title = daily_title,
                  id = date_suffix,
                  tags = vim.tbl_extend(
                    'force',
                    project_path_to_tags(project_path),
                    { 'daily-notes' }
                  ),
                  dir = vim.fs.joinpath('projects', project_path),
                  template = get_daily_template(project_path),
                  should_write = true,
                }
                local daily_note = note.create(tn)

                if daily_note then
                  note.open(daily_note)
                  print(
                    'Created daily note for ' .. project_path:gsub('/', ' → ')
                  )
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

-- List project directories and open main project file (updated for nested projects)
function M.list_projects()
  local projects_path = vim.fs.joinpath(Obsidian.dir.filename, 'projects')
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
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry:gsub('/', ' → '), -- Show hierarchy with arrows
              ordinal = entry,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              local project_path = selection.value
              -- Use verbose naming for project file
              local verbose_name = project_path:gsub('/', '-') .. '.md'
              local project_file =
                  vim.fs.joinpath(projects_path, project_path, verbose_name)
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
  vim.keymap.set('n', '<leader>wpnc', function()
    M.create_project(false)
  end, { desc = 'Create new project' })
  vim.keymap.set('n', '<leader>wpnf', function()
    M.create_project(true)
  end, { desc = 'Create project with full structure' })
  vim.keymap.set('n', '<leader>wpnn', function()
    M.create_nested_project(false)
  end, { desc = 'Create nested project' })
  vim.keymap.set('n', '<leader>wpnl', function()
    M.create_nested_project(true)
  end, { desc = 'Create nested project with full structure' })
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
  vim.keymap.set('n', '<leader>wr', function()
    M.refresh_daily_data()
  end, { desc = 'Refresh daily calendar and todos' })

  vim.keymap.set('n', '<leader>wd', function()
    require('plugin.obsidian-tasks').collect_tasks()
  end, {
    desc = 'Collect uncompleted tasks from daily files to backlog',
  })
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
