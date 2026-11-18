#!/usr/bin/env bash
set -o pipefail

DEST="/bays/storage/backup/"
MOUNT_DIR="/mnt/usb"

# 1. Define the rsync function
run_rsync() {
  if [[ -z "$MOUNT_DIR" || -z "$DEST" ]]; then
    echo "Error: MOUNT_DIR or DEST is not set."
    return 1
  fi

  echo "Starting rsync from $MOUNT_DIR/ TO $DEST."
  rsync -rtvP \
    --exclude='$RECYCLE.BIN' \
    --exclude='System Volume Information' \
    --exclude='.Trashes' \
    --exclude='.Spotlight-V100' \
    --exclude='.fseventsd' \
    --exclude='.DS_Store' \
    --exclude='._*' \
    --exclude='Thumbs.db' \
    "$MOUNT_DIR/" "$DEST"
}

# 
read -r DEV_NAME HOTPLUG_STATUS < <(lsblk -l -o NAME,HOTPLUG | awk '/^sd[a-z][0-9]/ && $2 == 1 { print $1, $2 }')
if [[ -z "$DEV_NAME" ]]; then
  echo "No hotplug partition found."
elif [[ "$HOTPLUG_STATUS" != "1" ]]; then
  echo "Warning: /dev/$DEV_NAME is NOT a hotplug device."
elif mountpoint -q "$MOUNT_DIR"; then
  echo "$MOUNT_DIR is already mounted."
  run_rsync
else 
  echo "Mounting /dev/$DEV_NAME to $MOUNT_DIR..."
  if mount "/dev/$DEV_NAME" "$MOUNT_DIR"; then
    run_rsync
  else
    echo "Error: Failed to mount /dev/$DEV_NAME."
  fi
fi
