#!/bin/bash

check_connection() {
	local_address=$(ip r | grep default | cut -d ' ' -f 3)
	
	if [[ $local_address ]]
	then
		ping -q -w 1 -c 1 $local_address > /dev/null && return 0 || return 1
	else
		return 1
	fi
}

set -e
source $1

# Start network manager
# To do: Switch to systemd-networkd.
systemctl start dhcpcd
systemctl enable dhcpcd

# Wait until connection is active.
until check_connection
do
	echo "Waiting for connection..."
	sleep 1
done

echo "Connected ok."

pacman -Syu

pacman -S --noconfirm ${packages[@]}

sed -i '/wheel ALL=(ALL) ALL$/s/^# //' /etc/sudoers
visudo --check

if [[ $? != 0 ]]
then
	echo "/etc/sudoers update failed."
	exit 1
fi

useradd -m -G wheel "${new_user}"

sudo -u ${new_user} "mkdir /home/${new_user}/AUR"

for pac in ${aur_packages[@]}
do
	cd "/home/${new_user}/AUR"
	sudo -u ${new_user} git clone "https://aur.archlinux.org/${pac}.git" "/home/${new_user}/AUR/${pac}"
	sudo -u ${new_user} makepkg
	pacman -U --noconfirm "*.pkg.tar.xz"
done
