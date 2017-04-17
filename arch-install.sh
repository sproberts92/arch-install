#!/bin/bash

# Exit if any individual command fails.
set -e
source $1

pacstrap /mnt base grub efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab

for loc in $locales
do
	arch-chroot /mnt sed -i "/${loc}/s/^#//" "/etc/locale.gen"
done

arch-chroot /mnt locale-gen

arch-chroot /mnt echo "LANG=${language}" > "/etc/locale.conf"

arch-chroot /mnt echo "${host_name}" > "/etc/hostname"
arch-chroot /mnt sed -i "/::1/a 127.0.1.1\t${host_name}.localdomain\t${host_name}" "/etc/hosts"

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=arch_grub
arch-chroot /mnt grub-mkconfig -o "/boot/grub/grub.cfg"

arch-chroot /mnt mkinitcpio -p linux

arch-chroot /mnt mkdir "/boot/EFI/boot"
arch-chroot /mnt cp "/boot/EFI/arch_grub/grubx64.efi" "/boot/EFI/boot/bootx64.efi"
