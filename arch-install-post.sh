#!/bin/bash

set -euo pipefail

source $1

# # Network manager
# systemctl enable dhcpcd

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
	(
		sudo -u ${new_user} git clone "https://aur.archlinux.org/${pac}.git" "/home/${new_user}/AUR/${pac}"
		pushd "/home/${new_user}/AUR/${pac}"
		source PKGBUILD && pacman -Sy --noconfirm --needed --asdeps "${makedepends[@]}" "${depends[@]}"
		sudo -u ${new_user} PKGEXT=".pkg.tar" makepkg
		pacman -U --noconfirm *.pkg.tar
		popd
	)
	# Subshell to keep variables sourced from PKGBUILD local - pacman shouldn't be run in parallel.
	# To do - git clones in parallel, makepkg too if possible.
	wait
done

sudo -u "${new_user}" git clone --bare "${dotfiles_repo}" "/home/${new_user}/${dotfiles_dir}"

rm -f "/home/${new_user}/.bash_logout" "/home/${new_user}/.bash_profile" "/home/${new_user}/.bashrc"
sudo -u "${new_user}" /usr/bin/git --git-dir="/home/${new_user}/${dotfiles_dir}/" --work-tree="/home/${new_user}" checkout

rm -- "$1"
rm -- "$0"
