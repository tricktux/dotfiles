#!/bin/sh

MESSAGE=$(cat)

alias_loc = $HOME/.config/neomutt/data/aliases.txt

NEWALIAS=$(echo "${MESSAGE}" \
	grep ^"From: " \
	sed s/[\,\"\']//g \
	awk '{$1=""; if (NF == 3) {print "alias" $0;} else if (NF == 2) {print "alias" $0 $0;} else if (NF > 3) {print "alias", tolower($(NF-1))"-"tolower($2) $0;}}')

# Create file if it doesnt exist
[ -f /etc/hosts ] || touch $alias_loc

if grep -Fxq "$NEWALIAS" $alias_loc; then
	:
else
	echo "$NEWALIAS" >> $alias_loc
fi

echo "${MESSAGE}"
