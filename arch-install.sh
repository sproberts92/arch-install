#!/bin/bash

# Exit if any individual command fails.
set -e

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

a_chroot 'bootctl --path=/boot install'

a_chroot 'cat << EOF > /boot/loader/loader.conf
default arch
timeout 2
editor 0
EOF'

# To do: Use PARTUUID instead of sda2.
a_chroot 'cat << EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
EOF'

cp "$(dirname $(realpath $0))/arch-install-post.sh" '/mnt/root'
cp "$(realpath $1)" '/mnt/root'

a_chroot "~/arch-install-post.sh ~/$(basename $1)"
