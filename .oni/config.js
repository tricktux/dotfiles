module.exports = {
	// Sat May 20 2017 21:06 Problems with oni
	// - Still very much in the devel phase
	// - Not much support for cpp
	// - No way to get around the quickOpen.execCommand which overwrites fzf History
  //add custom config here, such as
  "oni.useDefaultConfig": false,
  "oni.loadInitVim": true,
  "editor.fontSize": "12px",
  "oni.hideMenu": true,
  "editor.fontFamily": "Hack",
	"editor.quickOpen.execCommand": "rg --hidden --files ",
	"editor.completions.enabled": false
}
