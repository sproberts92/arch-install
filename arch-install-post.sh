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

systemctl start dhcpcd
systemctl enable dhcpcd

until check_connection
do
	echo "Waiting for connection..."
	sleep 1
done

echo "Connected ok."
