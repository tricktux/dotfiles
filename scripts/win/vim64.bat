REM //////////////3/12/2016 3:00:31 PM////////////////
REM //////////////8/31/2016 2:13:46 PM////////////////
REM Full developer setup
REM Installing Choco
choco install -y cmder
choco install -y git
choco install -y lua53
choco install -y python2 --version 2.7.9
REM choco install -y python
REM copy /Y C:\ProgramData\chocolatey\lib\lua53\tools\lua53.dll C:\ProgramData\chocolatey\lib\vim-x64.install\tools\vim74\
REM copy /Y C:\Windows\system32\python27.dll C:\ProgramData\chocolatey\lib\vim-x64.install\tools\vim74\
REM copy /Y C:\ProgramData\chocolatey\lib\python3\tools\python35.dll C:\ProgramData\chocolatey\lib\vim-x64.install\tools\vim74\
REM choco install -y python :: Installs python3
choco install -y ctags
choco install -y curl
choco install -y ag
REM Download rest of setup
REM   - cscope
REM   - vim
REM   - clang
REM   - MinGW

