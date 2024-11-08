local Pomodoro = {}
local timer = nil
local is_running = false

-- Default Configurations
local default_config = {
  work_duration = 25 * 60,     -- 25 minutes
  break_duration = 5 * 60      -- 5 minutes
}

-- Validate nvim version
local function check_version()
  local r = vim.fn.has("nvim-0.10") and true or false
  if not r then
    vim.notify("Pomodoro depends on nvim 0.10", vim.log.levels.ERROR)
  end
  return r
end

-- Active Configuration
local config = vim.deepcopy(default_config)

-- Current session and time left
local session = "work"           -- "work" or "break"
local time_left = config.work_duration

-- Utility function to send notifications
local function notify(message)
  vim.notify(message, vim.log.levels.INFO)
end

local function timer_stop()
  is_running = false
  timer:stop()
end

local function timer_start()
  if is_running then
    timer_stop()
  end

  is_running = true
  timer:start(1000, 1000, vim.schedule_wrap(function()
    time_left = time_left - 1
    if time_left <= 0 then
      timer_stop()
      notify(string.format("Finished Pomodoro %s session.", session))
    end
  end))
end

-- Function to toggle the Pomodoro timer
function Pomodoro.toggle()
  if not check_version() then return end

  if is_running then
    timer_stop()
    notify(string.format("Paused Pomodoro %s session.", session))
    return
  end

  timer_start()
  notify(string.format("Started Pomodoro %s session.", session))
end

-- Function to get elapsed time in the current session
function Pomodoro.get_elapsed_time()
  return math.floor(time_left / 60)
end

-- Function to skip current session and move to next
function Pomodoro.next()
  if not check_version() then return end

  if session == "work" then
    session = "break"
    time_left = config.break_duration
  else
    session = "work"
    time_left = config.work_duration
  end

  timer_start()
  notify(string.format("Started Pomodoro %s session.", session))
end

-- Function to configure Pomodoro timings
function Pomodoro.setup(user_config)
  if not check_version() then return end

  timer = vim.loop.new_timer()
  config = vim.tbl_extend('force', default_config, user_config)
  time_left = config.work_duration

  vim.api.nvim_create_user_command('PomodoroToggle', function()
    Pomodoro.toggle()
  end, {})

  vim.api.nvim_create_user_command('PomodoroNext', function()
    Pomodoro.next()
  end, {})
end

return Pomodoro
