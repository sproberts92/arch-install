#!/bin/bash

set -euo pipefail

source $1

# Create partitions
parted --script "${device}" \
	mklabel gpt \
	mkpart ESP fat32 1MiB 513MiB \
	set 1 boot on \
	mkpart primary ext4 513MiB 100%

boot_part="${device}1"
root_part="${device}2"

# Prepare encrypted root
if [[ "${encrypted_root}" == true ]]; then
	cryptsetup luksFormat --type luks2 "${root_part}"
	cryptsetup open "${root_part}" "cryptroot"
	root_part="/dev/mapper/cryptroot"
fi

# Format paritions
mkfs.vfat -F32 "${boot_part}"
mkfs.ext4 "${root_part}"

# Mount paritions
mount "${root_part}" "/mnt"

mkdir -p /mnt/boot
mount "${boot_part}" "/mnt/boot"
