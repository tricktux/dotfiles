@echo off
rem File:					cleantemp.bat
rem Description:			File that cleans temp on every boot
rem Author:				Reinaldo Molina <rmolin88@gmail.com>
rem Version:				0.0.0
rem Last Modified: Thu Jan 04 2018 16:40
rem Created: Sep 21 2017 15:19
rem File Goes In:  %appdata%\microsoft\windows\start menu\programs\startup\cleantemp.bat

cd %temp%
call :FuncCleanFilesAndFolders
cd C:\Windows\Prefetch
call :FuncCleanFilesAndFolders
cd C:\Windows\Temp
call :FuncCleanFilesAndFolders
goto :EOF

:FuncCleanFilesAndFolders
SETLOCAL
del /q *
for /d %%x in (*) do @rd /s /q "%%x"
ENDLOCAL

:EOF
