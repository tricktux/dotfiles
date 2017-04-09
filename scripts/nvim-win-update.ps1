# File:						nvim-win-update.ps1
# Description:		Update/Install Neovim & Universal Ctags for Windows 32/64 from AppVeyor
# Author:					Reinaldo Molina <rmolin88@gmail.com>
# Version:				1.0.0
# Last Modified:	Tue Apr 04 2017 14:24
# Created:				Mar 14 2017 13:30
# Arguments:
#		- arch (default = 64) anything else it uses the 32 bit neovim stuff
#	Example usage:
#		$powershell -file nvim-win-update.ps1 -arch 32
#		$powershell nvim-win-update.ps1

param([Int32]$arch=64) #Must be the first statement in your script

if ($arch -eq 64)
{
# Download neovim
		$neovim_link = "https://ci.appveyor.com/api/projects/neovim/neovim/artifacts/build/Neovim.zip?branch=master&job=Configuration%3A%20MINGW_64"
		$ctags = "https://ci.appveyor.com/api/buildjobs/tcojv7tm2gu2x91y/artifacts/ctags-7a2d6aeb-x64.zip"
}
else
{
		$neovim_link = "https://ci.appveyor.com/api/projects/neovim/neovim/artifacts/build/Neovim.zip?branch=master&job=Configuration%3A%20MINGW_32"
		$ctags = "https://ci.appveyor.com/api/buildjobs/32cw519c3onfadjk/artifacts/ctags-7a2d6aeb-x86.zip"
}

$res = wget $neovim_link -OutFile "$env:TEMP\neovim.zip"
$res_ctags = wget $ctags -OutFile "$env:TEMP\universal-ctags.zip"
if ($res -eq $null -and $res_ctags -eq $null)
{
		Remove-Item -path "C:\Program Files\nvim\Neovim" -force -recurse
		expand-archive -Path "$env:TEMP\neovim.zip" -DestinationPath "C:\Program Files\nvim" -Force
		expand-archive -Path "$env:TEMP\universal-ctags.zip" -DestinationPath "C:\Program Files\nvim\Neovim\bin" -Force
		if (Test-Path "C:\Program Files\Vim\vim80\spell\*.spl")
		{
				New-Item -path "C:\Program Files\nvim\Neovim\share\nvim\runtime" -name spell -itemtype directory
				Copy-Item "C:\Program Files\Vim\vim80\spell\en.ascii.spl" -Destination "C:\Program Files\nvim\Neovim\share\nvim\runtime\spell"
				Copy-Item "C:\Program Files\Vim\vim80\spell\en.latin1.spl"-Destination "C:\Program Files\nvim\Neovim\share\nvim\runtime\spell"
				Copy-Item "C:\Program Files\Vim\vim80\spell\en.utf-8.spl"-Destination "C:\Program Files\nvim\Neovim\share\nvim\runtime\spell"
		}
}
else
{
	Write-Host "wget failed to download neovim or ctags"
}
