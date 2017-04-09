#!/bin/bash

# Exit if any individual command fails.
set -e

# Verify boot mode
if [[ ! -d /sys/firmware/efi/efivars ]]; then
	echo "Cannot verify UEFI boot mode."
	exit 1
fi

# Set network time sync and timezone.
timedatectl set-ntp true
timedatectl set-timezone Europe/Amsterdam

# Partition disks
parted --script /dev/sda \
	mklabel gpt \
	mkpart ESP fat32 1MiB 513MiB \
	set 1 boot on \
	mkpart primary ext4 513MiB 100%

