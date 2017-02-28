wget "https://ci.appveyor.com/api/projects/neovim/neovim/artifacts/build/Neovim.zip?branch=master&job=Configuration%3A%20MINGW_64" `
	-OutFile "$env:TEMP\neovim.zip"

expand-archive -Path "$env:TEMP\neovim.zip" -DestinationPath "C:\Program Files\nvim" -Force
