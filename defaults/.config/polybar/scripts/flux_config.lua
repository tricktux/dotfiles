local _M = {}

-- Redshift command. Basically how to run the command.
-- Switches are provided as its own table
_M.redshift = {cmd = [[/usr/bin/redshift]], switches = {"-l", "manual"}}

-- Wal command. But with switches for day time and switches for night time
-- Switches are provided as its own table
_M.pywal = {
  cmd = [[/usr/bin/wal]],
  day = {
    "--theme", "base16-google", "-l", "-o",
    "/home/reinaldo/.config/polybar/launch.sh"
  },
  night = {
    "--theme", "base16-gruvbox-hard", "-o",
    "/home/reinaldo/.config/polybar/launch.sh"
  }
}

return _M
