#!/usr/bin/env bash

MOUNT_DIR="/mnt/usb"
DEST="/bays/storage/backup/"

# 1. Define the rsync function
run_rsync() {
  if [[ -z "$MOUNT_DIR" || -z "$DEST" ]]; then
    echo "Error: MOUNT_DIR or DEST is not set."
    return 1
  fi

  echo "Starting rsync from $MOUNT_DIR/ to $DEST..."
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

# 2. Match ONLY partitions whose subsystem chain includes "usb"
read -r DEV_NAME SUBSYS < <(lsblk -ln -o NAME,TYPE,SUBSYSTEMS | awk '$2 == "part" && $3 ~ /usb/ { print $1, $3 }')

if [[ -z "$DEV_NAME" ]]; then
  echo "No USB partition found."
elif mountpoint -q "$MOUNT_DIR"; then
  echo "$MOUNT_DIR is already mounted."
  run_rsync
else
  echo "Mounting /dev/$DEV_NAME to $MOUNT_DIR..."
  if mount -o ro,utf8 "/dev/$DEV_NAME" "$MOUNT_DIR"; then
    run_rsync
  else
    echo "Error: Failed to mount /dev/$DEV_NAME."
  fi
fi
