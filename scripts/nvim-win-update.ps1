# File:nvim-win-update.ps1
# Description: Update Neovim for Windows from AppVeyor
# Author:Reinaldo Molina <rmolin88@gmail.com>
# Version:1.0.0
# Last Modified: Tue Mar 14 2017 13:31
# Created: Mar 14 2017 13:30
Remove-Item -path "C:\Program Files\nvim\Neovim" -force -recurse
wget "https://ci.appveyor.com/api/projects/neovim/neovim/artifacts/build/Neovim.zip?branch=master&job=Configuration%3A%20MINGW_64" `
	-OutFile "$env:TEMP\neovim.zip"
expand-archive -Path "$env:TEMP\neovim.zip" -DestinationPath "C:\Program Files\nvim" -Force
