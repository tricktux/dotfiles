# Download vim-plug
md ~\vimfiles\autoload
$uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
(New-Object Net.WebClient).DownloadFile($uri, $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("~\vimfiles\autoload\plug.vim"))
# Donwload vim64.bat script from my github
md ~\
$uri = 'https://raw.githubusercontent.com/rmolin88/vimrc/vim64.bat'
(New-Object Net.WebClient).DownloadFile($uri, $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("~\vimfiles\autoload\plug.vim"))
# install chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
# run the vim64.bat script
cmd.exe /c '%HOME%\vim64.bat'
