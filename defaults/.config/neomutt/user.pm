# File:           user.pm
# Description:    Proton email information
# Author:		    Reinaldo Molina
# Email:          rmolin88 at gmail dot com
# Revision:	    0.0.0
# Last Modified: Wed Jan 30 2019 09:07


# IMAP folders
set my_drafts="Drafts"
set my_drafts_noquote="Drafts"
set my_sent="Sent"
set my_sent_noquote="Sent"
set my_trash="Archive"
set my_trash_noquote="Archive"

set my_username="molinamanso"
set my_domain="protonmail.com"
set my_password="`pass linux/\`hostname\`/proton`"

source "~/.config/neomutt/imap.gen.mutt"

# Specific to account
# Overwrite settings if you need to here
source "~/.config/neomutt/smtp.pm.mutt"

source "~/.config/neomutt/ui.mutt"
source "~/.config/neomutt/mappings.mutt"

macro   index   gi "<change-folder>=INBOX<enter>"       "Go to Inbox"
macro   index   gs "<change-folder>=$my_sent<enter>"    "Go to Sent"
macro   index   gd "<change-folder>=$my_drafts<enter>"  "Go to Drafts"
macro   index   gt "<change-folder>=Trash<enter>"		"Go to Trash"
macro   index   ga "<change-folder>=$my_trash<enter>"   "Go to Archive"
macro   index   gn "<change-folder>=Folders/Neo<enter>" "Go to Neo"

# vim: ft=neomuttrc
