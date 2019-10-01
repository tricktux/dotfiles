tmux \
	-f ~/.config/tmux/conf \
	new-session -n 'neomutt' \
	"tmux source-file ~/.config/tmux/neomutt.session"
