REM //////////////3/12/2016 3:00:31 PM////////////////
REM Full developer setup
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco install -y cmder
echo "Did the last command work? If it did go on. Else restart cmd to reload PATH"
pause
:: Copy download and set dot files
cd %HOME%
git clone https://github.com/rmolin88/vimrc
mklink _vimrc vimrc/_vimrc
mklink .gitconfig vimrc/.gitconfig
:: Download rest of setup
choco install -y vim-x64.install
choco install -y vim-x64
choco install -y lua53
choco install -y python2 --version 2.7.9
REM choco install -y python
copy /Y C:\ProgramData\chocolatey\lib\lua53\tools\lua53.dll C:\ProgramData\chocolatey\lib\vim-x64.install\tools\vim74\
copy /Y C:\Windows\system32\python27.dll C:\ProgramData\chocolatey\lib\vim-x64.install\tools\vim74\
copy /Y C:\ProgramData\chocolatey\lib\python3\tools\python35.dll C:\ProgramData\chocolatey\lib\vim-x64.install\tools\vim74\
REM choco install -y python :: Installs python3
choco install -y ctags
