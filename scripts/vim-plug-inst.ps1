# Download vim-plug
md ~\vimfiles\personal\undodir
md ~\vimfiles\autoload
$uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
(New-Object Net.WebClient).DownloadFile($uri, $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("~\vimfiles\autoload\plug.vim"))
# Donwload vimwiki tags pythong script
md ~\vimfiles\personal\wiki
$uri = 'https://raw.githubusercontent.com/vimwiki/utils/master/vwtags.py'
(New-Object Net.WebClient).DownloadFile($uri, $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("~\vimfiles\wiki\vwtags.py"))
# Donwload vim64.bat script from my github
#md ~\vimrc
#$uri = 'https://raw.githubusercontent.com/rmolin88/vimrc/vim64.bat'
#(New-Object Net.WebClient).DownloadFile($uri, $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("~\vimrc\vim64.bat"))
# Donwload vim32.bat script from my github
#md ~\vimrc
#$uri = 'https://raw.githubusercontent.com/rmolin88/vimrc/vim32.bat'
#(New-Object Net.WebClient).DownloadFile($uri, $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("~\vimrc\vim32.bat"))
# install chocolatey
# install chocolatey
#iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
# run the vim64.bat script
cmd.exe /c '%HOME%\vimrc\vim32.bat'
#cmd.exe /c '%HOME%\vimrc\vim64.bat'
