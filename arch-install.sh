#!/bin/bash

pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab
