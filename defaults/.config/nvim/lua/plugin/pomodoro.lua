local fmt = string.format
local Pomodoro = {}
local timer = nil
local is_running = false

-- Default Configurations
local default_config = {
  work_duration = 50 * 60,  -- 25 minutes (will be dynamic)
  break_duration = 10 * 60, -- 5 minutes
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
        Pomodoro.show_menu()
        notify(fmt('Finished Pomodoro %s session.', session))
      end
    end)
  )
end

-- Utility function to create floating windows
local function create_floating_window(content, title, callback)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- Calculate window size
  local width = math.max(40, #title + 10)
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

-- Function to show pomodoro duration selection
local function show_duration_menu()
  local content = {
    'Select Pomodoro Duration:',
    '',
    '1. 25 minutes (Classic)',
    '2. 50 minutes (Extended)',
    '',
    'Press number key or ESC to cancel',
  }

  create_floating_window(content, ' Pomodoro Duration ', function(choice)
    local duration
    local duration_name

    if choice == 1 then
      duration = 25 * 60
      duration_name = '25-minute'
    elseif choice == 2 then
      duration = 50 * 60
      duration_name = '50-minute'
    else
      return
    end

    config.work_duration = duration
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
    '1. Start Break (5 min)',
    '2. Start Pomodoro',
    '3. Discard/Stop Current',
    '',
    'Press number key or ESC to cancel',
  }

  create_floating_window(content, ' Pomodoro Menu ', function(choice)
    if choice == 1 then
      -- Start break
      timer_stop()
      session = 'break'
      time_left = config.break_duration
      timer_start()
      notify('Started 5-minute break session.')
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
  config = vim.tbl_extend('force', default_config, user_config)
  time_left = config.work_duration

  vim.api.nvim_create_user_command('PomodoroToggle', function()
    Pomodoro.toggle()
  end, {})

  vim.api.nvim_create_user_command('PomodoroNext', function()
    Pomodoro.next()
  end, {})

  -- New command for the floating menu
  vim.api.nvim_create_user_command('PomodoroMenu', function()
    Pomodoro.show_menu()
  end, {})

  -- Setup key mappings
  vim.keymap.set('n', '<leader>Pm', function()
    Pomodoro.show_menu()
  end, { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>Pt', function()
    Pomodoro.toggle()
  end, { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>Pn', function()
    Pomodoro.next()
  end, { noremap = true, silent = true })
end

return Pomodoro
