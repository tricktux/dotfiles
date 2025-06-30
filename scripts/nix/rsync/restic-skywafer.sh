#!/usr/bin/env bash

## my own rsync-based snapshot-style backup procedure
## (cc) marcio rps AT gmail.com

# NOTE: Please run script with sudo
# Also remember to copy ~./ssh to /root/

# config vars
# Fail as soon as a command fails
set -Eeuo pipefail

# Execute cleanup() if any of these sig events happen
trap cleanup SIGINT SIGTERM ERR #EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR #EXIT
  msg_error "==> Something went wrong..."
  read -n1 -r key
  exit $?
}

# Colors are only meant to be used with msg()
# Sample usage:
# msg "This is a ${RED}very important${NOFORMAT} message
setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' \
      BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' \
      YELLOW='\033[1;33m' BOLD='\033[1m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW='' \
      BOLD=''
  fi
}

msg() {
  echo >&2 -e "${1-}${2-}${NOFORMAT}"
  # Skip pretty characters
  notify-send 'restic backlaze skywafer backup' "${2}"
}
msg_error() {
  echo >&2 -e "${RED}${BOLD}${1-}${NOFORMAT}"
  notify-send 'restic backlaze skywafer backup' "${1:4:-3}" -u critical
}

setup_colors
echo >&2 -e "${CYAN}${BOLD}==>Backing up skywafer server<==${NOFORMAT}"

skywafer_ip="192.168.1.139"
cifs_opts="credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev,vers=3.0"
source_folders=(
  "$HOME/.mnt/skywafer/home"
  "$HOME/.mnt/skywafer/photo"
  "$HOME/.mnt/skywafer/video"
  "$HOME/.mnt/skywafer/shared"
  "$HOME/.mnt/skywafer/music"
)

bucket_name="skywafer-restic"
bucket_url="s3.us-west-000.backblazeb2.com"
bucket_type="s3"
restic_password=$(pass nas/synology/skywafer/restic)
backblaze_id=$(pass websites/backblaze.com/application-key-restic-id)
backblaze_key=$(pass websites/backblaze.com/application-key-restic-key)
folders=""
# repo="${bucket_type}:${bucket_url}/${bucket_name}"
repo="/mnt/usbstick/reinaldo/bkps/restic-repo"
# Mount the NAS folder if not already mounted
for folder in "${source_folders[@]}"; do
  last_folder=$(basename "$folder")
  if ! mountpoint -q "$folder"; then
    echo "Attempting to mount $folder"
    sudo mount -t cifs //"$skywafer_ip"/"$last_folder" "$folder" -o "$cifs_opts"
  fi
  folders="$folders $folder"
done

# # Initialize the backup repository if not already done
# if ! restic snapshots --repo "b2:${backblaze_id}:${backup_name}" >/dev/null 2>&1; then
# export AWS_ACCESS_KEY_ID="${backblaze_id}"
# export AWS_SECRET_ACCESS_KEY="${backblaze_key}"

# Command to init repo
# restic init --repo "$repo" --password-file <(echo "$restic_password")
# # Backup the source folder
restic \
  --verbose \
  --repo "$repo" \
  --password-file <(echo "$restic_password") \
  backup $folders
