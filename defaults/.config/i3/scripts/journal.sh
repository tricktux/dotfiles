# File:           journal.sh
# Description:    Launch editor for journal
# Author:		    Reinaldo Molina
# Email:          rmolin88 at gmail dot com
# Revision:	    0.0.0
# Created:        Thu Jan 17 2019 21:07
# Last Modified:  Thu Jan 17 2019 21:07

/usr/bin/nvim +UtilsEditJournal --listen /tmp/neovim_journal -i \
	~/.local/share/nvim/shada/journal.shada
