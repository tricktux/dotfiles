#SingleInstance Force ; if the script is updated, replace the one and only instance
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; SysGet, count, MonitorCount

; this is a must as the mouse coordinate are now relative to the whole screen
; (both monitors)
; CoordMode, Mouse, Screen

; Monitor 1 doesnt mean that is the left most, actually is the main monitor, 
; which is normally in the center
; SysGet, mon_1, Monitor, 1
; SysGet, mon_2, Monitor, 2
; SysGet, mon_3, Monitor, 3

; Can't figure out good mapping for this
; >+3::MouseMon3() ; Alt3
; >+1::MouseMon1() ; Alt1
; >+2::MouseMon2() ; Alt2
#`::CenterMouseOnActiveWindow()

; Excellent idea but it messes up with vim
; !j::Send {Down}
; !k::Send {Up}
; !h::Send {Left}
; !l::Send {Right}

; Awesomeness!
; Swap CapsLock and LCtrl
; Next level Awesomeness if possible:
LCtrl::CapsLock
CapsLock::LCtrl

; #+Up::CenterActiveWindowUp() ; if win+shift+↑ is pressed
; #+Down::CenterActiveWindowDown() ; if win+shift+↑ is pressed

#n::ToggleWinMinimize("Double Commander")
#;::ToggleWinMinimize("Cmd")
#p::ToggleWinMinimize("Outlook")
#w::ToggleWinMinimize("Wings")
#z::ToggleWinMinimize("Zeal")
; Skype
; #i::ToggleWinClass("LyncTabFrameHostWindowClass")
; Teams
#i::ToggleWinClass("Chrome_WidgetWin_1")
; Neovide
#o::ToggleWinClass("SDL_app")
; nvim-qt
; #o::ToggleWinClass("Qt5QWindowIcon")
; #p::ToggleWinClass("SUMATRA_PDF_FRAME")

#c::GetClass()

GetClass()
{
    WinGetClass, class, A
    MsgBox, The active windows class is "%class%".
}

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
            CenterMouseOnActiveWindow()
        }
    }
    Return
}


CenterMouseOnActiveWindow()
{
    Sleep 50
    CoordMode,Mouse,Screen
    WinGetPos, winTopL_x, winTopL_y, width, height, A
    winCenter_x := winTopL_x + width/2
    winCenter_y := winTopL_y + height/2
    ;MouseMove, X, Y, 0 ; does not work with multi-monitor
    DllCall("SetCursorPos", int, winCenter_x, int, winCenter_y)
    ;Tooltip winTopL_x:%winTopL_x% winTopL_y:%winTopL_y% winCenter_x:%winCenter_x% winCenter_y:%winCenter_y%
}

MouseMon3()
{
    new_x := mon_1Left + (mon_1Right - mon_1Left) // 2
    new_y := mon_1Top + (mon_1Bottom - mon_1Top) // 2
    MouseMove new_x, new_y
    DllCall("SetCursorPos", int, new_x, int, new_y) 
}

MouseMon2()
{
    new_x := mon_3Left + (mon_3Right - mon_3Left) // 2
    new_y := mon_3Top + (mon_3Bottom - mon_3Top) // 2
    MouseMove new_x, new_y
    DllCall("SetCursorPos", int, new_x, int, new_y) 
}


MouseMon1()
{
    new_x := mon_2Left + (mon_2Right - mon_2Left) // 2
    new_y := mon_2Top + (mon_2Bottom - mon_2Top) // 2
    ; MouseMove new_x, new_y
    DllCall("SetCursorPos", int, new_x, int, new_y) 
}

CenterActiveWindowDown()
{
    ; Get the window handle from de active window.
    winHandle := WinExist("A")

    VarSetCapacity(monitorInfo, 40)
    NumPut(40, monitorInfo)

    ; Get the current monitor from the active window handle.
    monitorHandle := DllCall("MonitorFromWindow", "uint", winHandle, "uint", 0x2)
    DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) 

    ; Get WorkArea bounding coordinates of the current monitor.
    A_Left   := NumGet(monitorInfo, 20, "Int")
    A_Top    := NumGet(monitorInfo, 24, "Int")
    A_Right  := NumGet(monitorInfo, 28, "Int")
    A_Bottom := NumGet(monitorInfo, 32, "Int")

    ; Calculate window coordinates.
    winW := (A_Right - A_Left) * 0.5 ; Change the factor here to your desired width.
    winH := A_Bottom*0.59
    winX := A_Left + (winW / 2)
    winY := A_Top + (winH*0.69)

    WinMove, A,, %winX%, %winY%, %winW%, %winH%
}

CenterActiveWindowUp()
{
    ; Get the window handle from de active window.
    winHandle := WinExist("A")

    VarSetCapacity(monitorInfo, 40)
    NumPut(40, monitorInfo)

    ; Get the current monitor from the active window handle.
    monitorHandle := DllCall("MonitorFromWindow", "uint", winHandle, "uint", 0x2)
    DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) 

    ; Get WorkArea bounding coordinates of the current monitor.
    A_Left   := NumGet(monitorInfo, 20, "Int")
    A_Top    := NumGet(monitorInfo, 24, "Int")
    A_Right  := NumGet(monitorInfo, 28, "Int")
    A_Bottom := NumGet(monitorInfo, 32, "Int")

    ; Calculate window coordinates.
    winW := (A_Right - A_Left) * 0.5 ; Change the factor here to your desired width.
    winH := A_Bottom*0.59
    winX := A_Left + (winW / 2)
    winY := A_Top + (winH*0.02)

    WinMove, A,, %winX%, %winY%, %winW%, %winH%
}
