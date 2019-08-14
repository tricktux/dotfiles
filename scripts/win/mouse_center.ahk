#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


#SingleInstance Force ; if the script is updated, replace the one and only instance

SysGet, count, MonitorCount

; this is a must as the mouse coordinate are now relative to the whole screen
; (both monitors)
CoordMode, Mouse, Screen

; Monitor 1 doesnt mean that is the left most, actually is the main monitor, 
; which is normally in the center
SysGet, mon_1, Monitor, 1
SysGet, mon_2, Monitor, 2
SysGet, mon_3, Monitor, 3

!3::
new_x := mon_1Left + (mon_1Right - mon_1Left) // 2
new_y := mon_1Top + (mon_1Bottom - mon_1Top) // 2
GoTo, Exit

!1::
new_x := mon_2Left + (mon_2Right - mon_2Left) // 2
new_y := mon_2Top + (mon_2Bottom - mon_2Top) // 2
GoTo, Exit

!2::
new_x := mon_3Left + (mon_3Right - mon_3Left) // 2
new_y := mon_3Top + (mon_3Bottom - mon_3Top) // 2

Exit:
MouseMove, %new_x%, %new_y%
return

!^w::

Input, UserInput, L1 C, {enter}.{esc}{tab}, h,p,c,g
if (UserInput = "g")
	Send, {backspace 4}by the way
else if (UserInput = "otoh")
	Send, {backspace 5}on the other hand
else if (UserInput = "fl")
	Send, {backspace 3}Florida
else if (UserInput = "ca")
	Send, {backspace 3}California
else if (UserInput = "ahk")
	Run, https://autohotkey.com
return

; Esc::ExitApp  ; Exit script with Escape key
