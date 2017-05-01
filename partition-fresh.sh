#!/bin/bash

# Create partitions
parted --script /dev/sda \
	mklabel gpt \
	mkpart ESP fat32 1MiB 513MiB \
	set 1 boot on \
	mkpart primary ext4 513MiB 100%

# Format paritions
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount root parition
mount /dev/sda2 /mnt

# Mount GPT parition
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
