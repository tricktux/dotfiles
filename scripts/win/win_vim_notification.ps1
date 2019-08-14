# File:           win_vim_notification.ps1
# Description:    Used by pomodoro.vim to notify of breaks
# Author:		    Reinaldo Molina
# Email:          rmolin88 at gmail dot com
# Revision:	    0.0.0
# Last Modified:  Wed Apr 25 2018 11:56
#

# Play some system sound
[System.Media.SystemSounds]::Asterisk.Play()   

$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Pomodoro Complete",0,"Vim Notification",0)
