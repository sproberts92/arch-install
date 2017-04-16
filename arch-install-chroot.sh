#!/bin/bash

source arch-install.cfg

for loc in $locales
do
	sed -i "/${loc}/s/^#//" "/etc/locale.gen"
done

locale-gen

echo "LANG=${language}" > "/etc/locale.conf"

echo "${hostn}" > "/etc/hostname"
sed -i "/::1/a 127.0.1.1\t${hostn}.localdomain\t${hostn}" hosts

grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=arch_grub
grub-mkconfig -o "/boot/grub/grub.cfg"

mkinitcpio -p linux

mkdir "/boot/EFI/boot"
cp "/boot/EFI/arch_grub/grubx64.efi" "/boot/EFI/boot/bootx64.efi"
