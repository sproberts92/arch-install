#!/bin/bash

set -e
source $1

# Network manager
systemctl enable dhcpcd

sed -i '/wheel ALL=(ALL) ALL$/s/^# //' /etc/sudoers
visudo --check

if [[ $? != 0 ]]
then
	echo "/etc/sudoers update failed."
	exit 1
fi

useradd -m -G wheel "${new_user}"

sudo -u ${new_user} mkdir "/home/${new_user}/AUR"

for pac in ${aur_packages[@]}
do
	cd "/home/${new_user}/AUR"
	sudo -u ${new_user} git clone "https://aur.archlinux.org/${pac}.git" "/home/${new_user}/AUR/${pac}"
	pushd "${pac}"
	sudo -u ${new_user} makepkg
	pacman -U --noconfirm *.pkg.tar.xz
	popd
done

rm -- "$1"
rm -- "$0"
