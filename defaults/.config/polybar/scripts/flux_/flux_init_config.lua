local _M = {}

-- Redshift command. Basically how to run the command.
-- Switches are provided as its own table
_M.redshift = {cmd = [[redshift]], switches = {"-p", "-l", "manual"}}

-- Wal command. But with switches for day time and switches for night time
-- Switches are provided as its own table
_M.pywal = {
  -- Skip reloading stuff
  cmd = [[wal]],
  day = {
    "--theme", "base16-google", "-l", "-o",
    [["$HOME/.config/polybar/scripts/flux_/flux_post_day"]]
  },
  sunrise = {
    "--theme", "solarized", "-l", "-o",
    [["$HOME/.config/polybar/scripts/flux_/flux_post_sunrise"]]
  },
  night = {
    "--theme", "base16-gruvbox-hard", "-o",
    [["$HOME/.config/polybar/scripts/flux_/flux_post_night"]]
  },
  sunset = {
    "--theme", "solarized", "-o",
    [["$HOME/.config/polybar/scripts/flux_/flux_post_sunset"]]
  }
}

_M.print = {enabled = false}

return _M
