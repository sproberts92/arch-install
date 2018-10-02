#!/bin/bash

set -euo pipefail

source $1

# Create partitions
parted --script "/dev/${device}" \
	mklabel gpt \
	mkpart ESP fat32 1MiB 513MiB \
	set 1 boot on \
	mkpart primary ext4 513MiB 100%

# Format paritions
mkfs.vfat -F32 "/dev/${device}1"
mkfs.ext4 "/dev/${device}2"

# Mount root parition
mount "/dev/${device}2" /mnt

# Mount GPT parition
mkdir -p /mnt/boot
mount "/dev/${device}1" /mnt/boot
