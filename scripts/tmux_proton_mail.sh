#!/usr/bin/env sh

tmux new-session \; \
	send-keys 'protonmail-bridge --cli' C-m \; \
	split-window -h \; \
	send-keys 'sleep 1 && neomutt -F ~/.config/neomutt/user.pm' C-m \; \
	resize-pane -Z \; 
