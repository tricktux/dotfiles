# Get the latest links from here:
# Python: https://www.python.org/downloads/windows/
# Python Pip: curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#	- python.exe get-pip.py --user
#	- This didnt really work
#	-_______-
#	- New approach: Download it form website
#	https://github.com/neovim/python-client/archive/0.2.6.tar.gz
#	- Too complex because most likely you also need to download the neovim pip dependencies
#	- Just get Lua and use neocomplete. Its still maintained.
# Universal-Ctags: https://github.com/universal-ctags/ctags-win32/releases
# RipGrep: https://github.com/BurntSushi/ripgrep/releases
# Lua: You dont really need it. But if you insist.
#	http://luarocks.github.io/luarocks/releases/
#	Wed Sep 19 2018 11:10: 
#	It turns out you do need it. deoplete requires neovim pip neovim.
#	Therefore, to enable 
#	This is actually a good link:
#	http://sourceforge.net/projects/luabinaries/files/5.3.3/Tools%20Executables/lua-5.3.3_Win64_bin.zip/download
#	http://sourceforge.net/projects/luabinaries/files/5.3.3/Tools%20Executables/lua-5.3.3_Win32_bin.zip/download
# 
# Cscope: https://www.softpedia.com/get/Programming/Other-Programming-Files/Cscope-for-Windows.shtml
# VS2015C++ Runtime Engine: https://www.microsoft.com/en-us/download/details.aspx?id=48145
# doublecmd: https://sourceforge.net/p/doublecmd/wiki/Download/
#
# Extract vim64.7z to vim-64/vim8x
# Then create vim-64/vim8x/utils
# Then extract all of the other downloads there.
# Vim will add each one of them to the path.

$curr_dir = (Get-Item -Path ".\\").FullName
$vim_64_links = @("http://tuxproject.de/projects/vim/complete-x64.7z",
		"https://github.com/universal-ctags/ctags-win32/releases/download/2018-09-05%2F0d87063f/ctags-2018-09-05_0d87063f-x64.zip",
		"https://www.python.org/ftp/python/3.7.0/python-3.7.0-embed-amd64.zip",
		"https://github.com/BurntSushi/ripgrep/releases/download/0.9.0/ripgrep-0.9.0-x86_64-pc-windows-gnu.zip"
		)

$executable_links = @("https://www.softpedia.com/get/Programming/Other-Programming-Files/Cscope-for-Windows.shtml#download")

$installer_links = @("https://www.python.org/ftp/python/2.7.15/python-2.7.15.amd64.msi",
					"https://www.microsoft.com/en-us/download/confirmation.aspx?id=48145"
					)

if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  

# Hard Coded to vim_64 folder
function Download-Link-To-Location {
	param ( [string]$Name, [string]$Link )

	$temp = "$env:TEMP\$Name"
	$res = wget $Link -OutFile "$temp"

	if ($res -ne $null){ return "Failed to donwload: $Name" }

	sz x -y -o"vim_64" "$temp"
	return 1
}

Download-Link-To-Location "vim64.7z" $vim_64_links[0]
Download-Link-To-Location "ctags.zip" $vim_64_links[1]
Download-Link-To-Location "python3.zip" $vim_64_links[2]
Download-Link-To-Location "ripgrep.zip" $vim_64_links[3]

Write-Host "All done. Hopefully it worked."
