#!/bin/bash

pacstrap /mnt base grub efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab

cat arch-install-chroot.sh | arch-chroot /mnt
