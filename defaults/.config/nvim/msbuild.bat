@echo off
REM VS2010
REM C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe ^
REM VS2015
REM "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" ^
REM VS2017
REM "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe" ^
REM VS2022
c:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe ^
/maxcpucount ^
/nologo ^
/verbosity:quiet ^
/target:Build ^
/property:GenerateFullPath=true ^
/property:Configuration=Release ^
/property:Platform=x64 ^
/l:FileLogger,Microsoft.Build.Engine;logfile=Manual_MSBuild_ReleaseVersion_LOG.log ^
PHX_GUI/PHX_GUI.sln
