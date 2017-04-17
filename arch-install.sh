#!/bin/bash

# Exit if any individual command fails.
set -e
source $1

pacstrap /mnt base grub efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab

a_chroot() {
	arch-chroot /mnt /bin/bash -c $1
}

for loc in $locales
do
	a_chroot 'sed -i "/${loc}/s/^#//" "/etc/locale.gen"'
done

a_chroot 'locale-gen'

a_chroot 'echo "LANG=${language}" > "/etc/locale.conf"'

a_chroot 'echo "${host_name}" > "/etc/hostname"'
a_chroot 'sed -i "/::1/a 127.0.1.1\t${host_name}.localdomain\t${host_name}" "/etc/hosts"'

a_chroot 'grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=arch_grub'
a_chroot 'grub-mkconfig -o "/boot/grub/grub.cfg"'

a_chroot 'mkinitcpio -p linux'

a_chroot 'mkdir "/boot/EFI/boot"'
a_chroot 'cp "/boot/EFI/arch_grub/grubx64.efi" "/boot/EFI/boot/bootx64.efi"'
