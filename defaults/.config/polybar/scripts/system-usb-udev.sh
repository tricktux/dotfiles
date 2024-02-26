#!/usr/bin/env bash

case "$1" in
--mount)
  devices=$(lsblk -Jplno NAME,TYPE,RM,MOUNTPOINT)

  for mount in $(echo "$devices" | jq -r '.blockdevices[] | select(.type == "part") | select(.rm == true) | select(.mountpoint == null) | .name'); do
    udisksctl mount --no-user-interaction -b "$mount"
  done

  ;;
--unmount)
  devices=$(lsblk -Jplno NAME,TYPE,RM,MOUNTPOINT)

  for unmount in $(echo "$devices" | jq -r '.blockdevices[] | select(.type == "part") | select(.rm == true) | select(.mountpoint != null) | .name'); do
    udisksctl unmount --no-user-interaction -b "$unmount"
    udisksctl power-off --no-user-interaction -b "$unmount"
  done

  ;;
esac
