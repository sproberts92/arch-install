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
