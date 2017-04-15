#!/bin/bash

declare -a locales=("en_AU.UTF-8" "en_GB.UTF-8" "en_US.UTF-8")

for loc in "${locales[@]}"
do
	sed -i "/${loc}/s/^#//" "locale.gen"
done

locale-gen

echo "LANG=en_AU.UTF-8" > "/etc/locale.conf"
