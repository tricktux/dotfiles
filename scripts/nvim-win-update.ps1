# File:nvim-win-update.ps1
# Description: Update Neovim for Windows from AppVeyor
# Author:Reinaldo Molina <rmolin88@gmail.com>
# Version:1.0.0
# Last Modified: Mon Mar 20 2017 12:22
# Created: Mar 14 2017 13:30
$res = wget "https://ci.appveyor.com/api/projects/neovim/neovim/artifacts/build/Neovim.zip?branch=master&job=Configuration%3A%20MINGW_64" `
	-OutFile "$env:TEMP\neovim.zip"
if ($res -eq $null)
{
	Remove-Item -path "C:\Program Files\nvim\Neovim" -force -recurse
	expand-archive -Path "$env:TEMP\neovim.zip" -DestinationPath "C:\Program Files\nvim" -Force
}
else
{
	Write-Host "wget failed"	
}
