set history save on
# Infinite size
set history size -1
# Remove all duplicates
set history remove-duplicates -1
set history filename ~/.gdbhistory

# Disable python loading
# set auto-load python-scripts off

source /usr/share/gdb-dashboard/.gdbinit
