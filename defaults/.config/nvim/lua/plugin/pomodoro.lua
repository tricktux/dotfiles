local fmt = string.format
local Pomodoro = {}
local timer = nil
local is_running = false

-- Default Configurations
local default_config = {
  work_duration = 25 * 60, -- 25 minutes (will be dynamic)
  break_duration = 1 * 60, -- 5 minutes
}

-- Validate nvim version
local function check_version()
  local r = vim.fn.has('nvim-0.10') and true or false
  if not r then
    vim.notify('Pomodoro depends on nvim 0.10', vim.log.levels.ERROR)
  end
  return r
end

-- Active Configuration
local config = vim.deepcopy(default_config)

-- Current session and time left
local session = 'work' -- "work" or "break"
local time_left = config.work_duration

-- Forward declarations to avoid circular dependencies
local show_completion_menu
local show_duration_menu

-- Utility function to send notifications
local function notify(message)
  vim.notify(message, vim.log.levels.INFO)
end

local function timer_stop()
  is_running = false
  if timer then
    timer:stop()
  end
end

-- Generic menu window function (DRY solution)
local function show_menu_window(content, title, callback)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- Calculate window size
  local width = math.max(50, #title + 10)
  for _, line in ipairs(content) do
    width = math.max(width, #line + 4)
  end
  local height = #content + 2

  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Set window-local mappings
  local opts = { noremap = true, silent = true, buffer = buf }

  -- Number key mappings for selections
  for i = 1, #content do
    if content[i]:match('^%d+%.') then -- Only map if line starts with number
      local num = content[i]:match('^(%d+)%.')
      vim.keymap.set('n', num, function()
        vim.api.nvim_win_close(win, true)
        callback(tonumber(num))
      end, opts)
    end
  end

  -- ESC and q to close
  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, opts)

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, opts)

  return win
end

local function timer_start()
  if is_running then
    timer_stop()
  end

  is_running = true
  timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      time_left = time_left - 1
      if time_left <= 0 then
        timer_stop()
        show_completion_menu()
      end
    end)
  )
end

-- Function to show completion menu when timer expires
show_completion_menu = function()
  local completed_session = session == 'work' and 'Pomodoro' or 'Break'
  local content = {
    fmt('✅ %s session completed!', completed_session),
    '',
    'What would you like to do next?',
    '',
  }

  if session == 'work' then
    -- Just finished work session
    table.insert(content, fmt('1. Start Break (%d min)', config.break_duration / 60))
    table.insert(content, '2. Start Another Pomodoro')
    table.insert(content, '3. Finish for now')
  else
    -- Just finished break session
    table.insert(content, '1. Start Pomodoro')
    table.insert(content, fmt('2. Extend Break (%d more min)', config.break_duration / 60))
    table.insert(content, '3. Finish for now')
  end

  table.insert(content, '')
  table.insert(content, 'Press number key or ESC to dismiss')

  show_menu_window(content, ' Session Complete ', function(choice)
    if session == 'work' then
      if choice == 1 then
        -- Start break
        session = 'break'
        time_left = config.break_duration
        timer_start()
        notify(fmt('Started %d-minute break session.', config.break_duration / 60))
      elseif choice == 2 then
        -- Start another pomodoro
        show_duration_menu()
      end
      -- choice == 3 or other: do nothing
    else
      if choice == 1 then
        -- Start pomodoro
        show_duration_menu()
      elseif choice == 2 then
        -- Extend break
        time_left = config.break_duration
        timer_start()
        notify(fmt('Extended break for %d more minutes.', config.break_duration / 60))
      end
      -- choice == 3 or other: do nothing
    end
  end)
end

-- Function to show pomodoro duration selection
show_duration_menu = function()
  local content = {
    'Select Pomodoro Duration:',
    '',
    '1. 25 minutes (Classic)',
    fmt('2. %d minutes (Configured)', config.work_duration / 60),
    '',
    'Press number key or ESC to cancel',
  }

  show_menu_window(content, ' Pomodoro Duration ', function(choice)
    local duration
    local duration_name

    if choice == 1 then
      duration = 25 * 60
      duration_name = '25-minute'
    elseif choice == 2 then
      duration = config.work_duration
      duration_name = fmt('%d-minute', duration / 60)
    else
      return
    end

    time_left = duration
    session = 'work'
    timer_start()
    notify(fmt('Started %s Pomodoro session.', duration_name))
  end)
end

-- Function to show main pomodoro menu
function Pomodoro.show_menu()
  if not check_version() then
    return
  end

  local status = is_running and 'Running' or 'Stopped'
  local current_session = session == 'work' and 'Pomodoro' or 'Break'
  local remaining_min = math.ceil(time_left / 60)

  local content = {
    fmt('Status: %s %s (%d min left)', status, current_session, remaining_min),
    '',
    fmt('1. Start Break (%d min)', config.break_duration / 60),
    '2. Start Pomodoro',
    '3. Discard/Stop Current',
    '',
    'Press number key or ESC to cancel',
  }

  show_menu_window(content, ' Pomodoro Menu ', function(choice)
    if choice == 1 then
      -- Start break
      timer_stop()
      session = 'break'
      time_left = config.break_duration
      timer_start()
      notify(fmt('Started %d-minute break session.', config.break_duration / 60))
    elseif choice == 2 then
      -- Start pomodoro - show duration menu
      timer_stop()
      show_duration_menu()
    elseif choice == 3 then
      -- Discard/Stop current
      if is_running then
        timer_stop()
        notify('Stopped current session.')
      else
        notify('No active session to stop.')
      end
    end
  end)
end

-- Function to toggle the Pomodoro timer
function Pomodoro.toggle()
  if not check_version() then
    return
  end

  if is_running then
    timer_stop()
    notify(fmt('Paused Pomodoro %s session.', session))
    return
  end

  timer_start()
  notify(fmt('Started Pomodoro %s session.', session))
end

-- Function to get elapsed time in the current session
function Pomodoro.get_session_info()
  if not is_running then
    return {}
  end
  return {
    name = session,
    remaining_time_m = math.floor(time_left / 60),
  }
end

-- Function to skip current session and move to next
function Pomodoro.next()
  if not check_version() then
    return
  end

  if session == 'work' then
    session = 'break'
    time_left = config.break_duration
  else
    session = 'work'
    time_left = config.work_duration
  end

  timer_start()
  notify(fmt('Started Pomodoro %s session.', session))
end

-- Function to configure Pomodoro timings
function Pomodoro.setup(user_config)
  if not check_version() then
    return
  end

  timer = vim.loop.new_timer()
  config = vim.tbl_extend('force', default_config, user_config or {})
  time_left = config.work_duration

  vim.api.nvim_create_user_command('PomodoroToggle', function()
    Pomodoro.toggle()
  end, {})

  vim.api.nvim_create_user_command('PomodoroNext', function()
    Pomodoro.next()
  end, {})

  vim.api.nvim_create_user_command('PomodoroMenu', function()
    Pomodoro.show_menu()
  end, {})

  -- Set up key mappings
  vim.keymap.set('n', '<Leader>Pt', function()
    Pomodoro.toggle()
  end, { noremap = true, silent = true, desc = 'pomodoro-toggle' })
  vim.keymap.set('n', '<Leader>Pn', function()
    Pomodoro.next()
  end, { noremap = true, silent = true, desc = 'pomodoro-next' })
  vim.keymap.set('n', '<Leader>Pm', function()
    Pomodoro.show_menu()
  end, { noremap = true, silent = true, desc = 'pomodoro-show-menu' })
end

return Pomodoro
