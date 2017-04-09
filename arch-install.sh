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

