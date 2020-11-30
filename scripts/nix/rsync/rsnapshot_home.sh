#!/bin/bash

## my own rsync-based snapshot-style backup procedure
## (cc) marcio rps AT gmail.com

# NOTE: Please run script with sudo

# config vars

SRC="/home/reinaldo/.gnupg /home/reinaldo/.ssh /home/reinaldo/.password-store" #dont forget trailing slash!
# SNAP="/snapshots/username"
SNAP="/home/reinaldo/.mnt/skynfs/$HOSTNAME"
OPTS="-rltgoi --delay-updates --delete --chmod=a-w --copy-links --mkpath"
MINCHANGES=20

rsync $OPTS $SRC $SNAP/latest >>$SNAP/rsync.log

# check if enough has changed and if so
# make a hardlinked copy named as the date

COUNT=$(wc -l $SNAP/rsync.log | cut -d" " -f1)
if [ "$COUNT" -gt "$MINCHANGES" ]; then
  DATETAG=$(date +%Y-%m-%d)
  if [ ! -e $SNAP/$DATETAG ]; then
    cp -al $SNAP/latest $SNAP/$DATETAG
    chmod u+w $SNAP/$DATETAG
    mv $SNAP/rsync.log $SNAP/$DATETAG
    chmod u-w $SNAP/$DATETAG
  fi
fi
