# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
export PATH=/opt/gcc-arm-none-eabi-4_9-2015q3/bin:$PATH
export PATH=/opt/avr8-gnu-toolchain-linux_x86_64/bin:$PATH
export PATH=/home/reinaldo/Documents/autotest:$PATH
export PATH=/home/reinaldo/Documents/ardupilot_code/ardupilot/Tools/scripts/ardupilot/Tools/autotest:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export CPATH=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include:$CPATH
#export CPATH=/lib/modules/4.6.0-rc1/build/include

