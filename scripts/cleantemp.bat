@echo off
rem File:					cleantemp.bat
rem Description:			File that cleans temp on every boot
rem Author:				Reinaldo Molina <rmolin88@gmail.com>
rem Version:				0.0.0
rem Last Modified: Sep 21 2017 15:19
rem Created: Sep 21 2017 15:19
rem File Goes In:  %appdata%\microsoft\windows\start menu\programs\startup\cleantemp.bat


rd %temp% /s /q
md %temp%
rd c:\TEMP /s /q
md c:\TEMP
REM  Fri Nov 17 2017 11:30 Make this work 
rd C:\Windows\Temp /s /q
md C:\Windows\Temp
