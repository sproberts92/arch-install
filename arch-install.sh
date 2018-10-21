#!/bin/bash

# Exit if any individual command fails.
set -euo pipefail

# Load config.
source $1

pacstrap /mnt base base-devel "${packages[@]}"
genfstab -U /mnt >> /mnt/etc/fstab

a_chroot() {
	arch-chroot /mnt /bin/bash -c "${1}"
}

# Uncomment the desired locales in '/etc/locale.gen'.
for loc in $locales
do
	a_chroot 'sed -i "/'"${loc}"'/s/^#//" "/etc/locale.gen"'
done

a_chroot 'locale-gen'

a_chroot 'echo "LANG='"${language}"'" > "/etc/locale.conf"'

a_chroot "ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime"
a_chroot "hwclock --systohc"

a_chroot 'echo "'"${host_name}"'" > "/etc/hostname"'
a_chroot 'sed -i "/::1/a 127.0.1.1\t'"${host_name}"'.localdomain\t'"${host_name}"'" "/etc/hosts"'

# Less elegant than using patch, but more robust to future changes to the default mkinitcpio.conf.
if [ "${encrypted_root}" = true ]; then
	a_chroot 'sed -i "/^HOOKS=/a HOOKS=(base systemd autodetect keyboard modconf block sd-encrypt filesystems fsck)" "/etc/mkinitcpio.conf"'
	a_chroot 'sed -i "0,/^HOOKS=/s/^HOOKS=/#\tHOOKS=/" "/etc/mkinitcpio.conf"'
	a_chroot 'mkinitcpio -p linux'
fi

a_chroot 'bootctl --path=/boot install'

a_chroot 'cat << EOF > /boot/loader/loader.conf
default arch
timeout 2
editor 0
EOF'

a_chroot "cat << EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options rd.luks.name=$(lsblk -ro FSTYPE,UUID | awk '/crypto_LUKS/ {print $2}')=cryptroot root=/dev/mapper/cryptroot quiet loglevel=0 vga=current ipv6.disable=1
EOF"

cp "$(dirname $(realpath $0))/arch-install-post.sh" '/mnt/root'
cp "$(realpath $1)" '/mnt/root'

a_chroot "~/arch-install-post.sh ~/$(basename $1)"
