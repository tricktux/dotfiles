local utl = require('utils.utils')

local M = {}

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
