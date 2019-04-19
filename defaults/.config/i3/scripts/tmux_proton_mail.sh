#!/usr/bin/env sh

new_journal () {
	tmux attach \; \
		new-window -n 'journal' \; \
		send-keys 'source ~/.config/i3/scripts/journal.sh' C-m \;
}

new_psu () {
	tmux attach \; \
		new-window -n 'psu' \; \
		send-keys 'neomutt -F ~/.config/neomutt/user.psu' C-m \;
}

new_gmail () {
	tmux attach \; \
		new-window -n 'gmail' \; \
		send-keys 'neomutt -F ~/.config/neomutt/user.gmail' C-m \;
}

new_cmus () {
	tmux attach \; \
		new-window -n 'cmus' \; \
		send-keys 'cmus' C-m \;
}

new_ranger () {
	tmux attach \; \
		new-window -n 'ranger' \; \
		send-keys 'ranger' C-m \;
}

new_proton () {
	tmux attach \; \
		new-window -n 'proton' \; \
		send-keys 'protonmail-bridge --cli' C-m \; \
		split-window -h \; \
		send-keys 'sleep 1 && neomutt -F ~/.config/neomutt/user.pm' C-m \; \
		resize-pane -Z \; 
}

for i in "$@"; do
	case "$i" in
		--proton) new_proton ;;
		--ranger) new_ranger ;;
		--gmail) new_gmail ;;
		--psu) new_psu ;;
		--journal) new_journal ;;
		*) exit;;
	esac
done

i3-msg "scratchpad show"
