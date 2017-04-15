#!/bin/bash

pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

cat arch-install-chroot.sh | arch-chroot /mnt
