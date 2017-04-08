#!/bin/bash

# Verify boot mode
if [[ ! -d /sys/firmware/efi/efivars ]]; then
	echo "Cannot verify UEFI boot mode."
	exit 1
fi

