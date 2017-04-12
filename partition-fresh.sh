#!/bin/bash

# Create disk partitions
parted --script /dev/sda \
	mklabel gpt \
	mkpart ESP fat32 1MiB 513MiB \
	set 1 boot on \
	mkpart primary ext4 513MiB 100%
