local _M = {}

-- Redshift command. Basically how to run the command.
-- Switches are provided as its own table
_M.redshift = {cmd = [[/usr/bin/redshift]], switches = {"-p", "-l", "manual"}}

-- Wal command. But with switches for day time and switches for night time
-- Switches are provided as its own table
_M.pywal = {
  cmd = '/usr/bin/wal',
  day = {
    "--theme", "base16-google", "-l", "-q", "-o",
    "'/home/reinaldo/.config/polybar/scripts/flux_/flux_post_day'"
  },
  sunrise = {
    "--theme", "solarized", "-l", "-q", "-o",
    "'/home/reinaldo/.config/polybar/scripts/flux_/flux_post_sunrise'"
  },
  night = {
    "--theme", "base16-gruvbox-hard", "-q", "-o",
    "'/home/reinaldo/.config/polybar/scripts/flux_/flux_post_night'"
  },
  sunset = {
    "--theme", "solarized", "-q", "-o",
    "'/home/reinaldo/.config/polybar/scripts/flux_/flux_post_sunset'"
  }
}

-- Font: Weather Icons
_M.print = {
  enabled = true,
  day = "  ",
  night = "  ",
  sunrise = "  ",
  sunset = "  "
}

return _M
