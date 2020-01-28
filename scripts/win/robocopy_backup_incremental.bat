REM File:           robocopy_backup_incremental.bat
REM Description:    Perform a backup, incrementally
REM Author:		    Reinaldo Molina
REM Email:          rmolin88 at gmail dot com
REM Revision:	    0.0.0
REM Created:        Fri May 24 2019 15:10
REM Last Modified:  Fri May 24 2019 15:10

REM  Swtiches meaning:
REM  - /MIR: Mirror src in dst
REM  - /W:0 zero wait times for retries
REM  - /R:1 one time retries
REM  - /MT:32 threads to use
REM  - /XA:SH include system files, DONT USE
REM  - /V verbose status
REM	 - /FFT is a very important option, as it allows a 2-second difference when
REM	 comparing timestamps of files, such that minor clock differences between
REM	 your computer and your backup device don't matter. This will ensure that
REM	 only modified files are copied over, even if file modification times are
REM	 not exactly synchronized.
REM	 - /Z copies files in "restart mode", so partially copied files can be
REM	 continued after an interruption
REM	 - /NP and /NDL suppress some debug output
REM	 - /XJD excludes "junction points" for directories, symbolic links that
REM	 might cause problems like infinite loops during backup

REM  @echo off

setlocal enabledelayedexpansion

set dirs[0]=%USERPROFILE%\Documents\apps
set dirs[1]=%USERPROFILE%\AppData\Roaming\gnupg
set dirs[2]=%USERPROFILE%\.password-store
set dirs[3]=D:\1.WINGS
set dirs[4]=D:\2.Office
set dirs[5]=D:\3.Other
set dirs[6]=D:\cdats
set dirs[7]=D:\wiki
set dirs[8]=D:\wings-dev
REM  set dirs[9]=pip
REM  set dirs[10]=frosted
REM  set dirs[11]=pep8
REM  set dirs[12]=pylint
REM  set dirs[13]=neovim

set dest=G:\StationBackups\reinaldo_laptop


for /l %%n in (0,1,8) do ( 
	REM Fast copy
	REM  robocopy "!dirs[%%n]!" %dest% /MIR /W:0 /R:1 /MT:8 /FFT /XJD /NP /NDL /Z /ETA
	REM Slower copy
	robocopy "!dirs[%%n]!" "%dest%" /MIR /W:0 /R:1 /MT:2 /FFT /XJD /NP /NDL /Z /ETA
)
