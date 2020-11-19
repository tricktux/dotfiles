@echo off
REM VS2010
REM C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe ^
REM VS2015
REM "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" ^
REM VS2017
"C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe" ^
/maxcpucount ^
/nologo ^
/verbosity:quiet ^
/target:Build ^
/property:GenerateFullPath=true ^
PHX_GUI/PHX_GUI.sln
