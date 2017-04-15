#!/bin/bash

pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt "./arch-install-chroot.sh"
