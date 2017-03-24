# File:nvim-win-update.ps1
# Description: Update Neovim for Windows from AppVeyor
# Author:Reinaldo Molina <rmolin88@gmail.com>
# Version:1.0.0
# Last Modified: Mon Mar 20 2017 12:22
# Created: Mar 14 2017 13:30

# Download neovim
$neovim_link = "https://ci.appveyor.com/api/projects/neovim/neovim/artifacts/build/Neovim.zip?branch=master&job=Configuration%3A%20MINGW_64"
$res = wget $neovim_link -OutFile "$env:TEMP\neovim.zip"
if ($res -eq $null)
{
	Remove-Item -path "C:\Program Files\nvim\Neovim" -force -recurse
	expand-archive -Path "$env:TEMP\neovim.zip" -DestinationPath "C:\Program Files\nvim" -Force
}
else
{
	Write-Host "wget failed to download neovim"	
}

# Download ctags 64
# $ctags_32 = "https://ci.appveyor.com/api/buildjobs/32cw519c3onfadjk/artifacts/ctags-7a2d6aeb-x86.zip"
# $ctags_64 = "https://ci.appveyor.com/api/buildjobs/tcojv7tm2gu2x91y/artifacts/ctags-7a2d6aeb-x64.zip"
# $res = wget $ctags_32 -OutFile "$env:TEMP\universal-ctags_32.zip"; $res = wget $ctags_64 -OutFile "$env:TEMP\universal-ctags.zip"
# if ($res -eq $null)
# {
	# # Remove-Item -path "C:\Program Files\nvim\Neovim\nvim\ctags.exe" -force -recurse
	# expand-archive -Path "$env:TEMP\universal-ctags.zip" -DestinationPath "C:\Program Files\nvim\Neovim\bin" -Force
	# expand-archive -Path "$env:TEMP\universal-ctags.zip" -DestinationPath "D:\wings-dev\PortableVim\vim64\vim80" -Force
	# expand-archive -Path "$env:TEMP\universal-ctags_32.zip" -DestinationPath "D:\wings-dev\PortableVim\vim32\vim80" -Force
# }
# else
# {
	# Write-Host "wget failed to download universal-ctags"	
# }
