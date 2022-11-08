; https://www.autohotkey.com/boards/viewtopic.php?t=6413
;OPTIMIZATIONS START
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
;OPTIMIZATIONS END

; YOUR_SCRIPT_HERE
#SingleInstance Force ; if the script is updated, replace the one and only instance
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#m::WinMinimize, A
^!m::Send, {Volume_Mute}
^!j::Send, {Volume_Down}
^!k::Send, {Volume_Up}
^!h::Send, {Media_Play_Pause}

; Use Window Spy from AutoHotkey to get accurate window names
#n::ToggleWinMinimize("Double Commander")
#p::ToggleWinMinimize("Outlook")
; Neovide
; #o::ToggleWinClass("SDL_app")
; nvim-qt
#o::ToggleWinClass("Qt5152QWindowIcon")
; #p::ToggleWinClass("SUMATRA_PDF_FRAME")

ToggleWinClass(TheWindowClass)
{
    SetTitleMatchMode,2
    DetectHiddenWindows, Off
    IfWinActive, ahk_class %TheWindowClass%
    {
        WinMinimize, ahk_class %TheWindowClass%
    }
    Else
    {
        IfWinExist, ahk_class %TheWindowClass%
        {
            WinGet, winid, ID, ahk_class %TheWindowClass%
            DllCall("SwitchToThisWindow", UInt, winid, UInt, 1)
        }
    }
    Return
}

ToggleWinMinimize(TheWindowTitle)
{
    SetTitleMatchMode,2
    DetectHiddenWindows, Off
    IfWinActive, %TheWindowTitle%
    {
        WinMinimize, %TheWindowTitle%
    }
    Else
    {
        IfWinExist, %TheWindowTitle%
        {
            WinGet, winid, ID, %TheWindowTitle%
            DllCall("SwitchToThisWindow", UInt, winid, UInt, 1)
            Sleep 10
        }
    }
    Return
}
