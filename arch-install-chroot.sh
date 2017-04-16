#!/bin/bash

source arch-install.cfg

for loc in $locales
do
	sed -i "/${loc}/s/^#//" "/etc/locale.gen"
done

locale-gen

echo "LANG=${language}" > "/etc/locale.conf"
