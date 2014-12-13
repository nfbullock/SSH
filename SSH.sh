#!/bin/bash

function display {
	hostnum=1
	echo ""
	echo "Where would you like to jump?"
	echo "-----------------------------"
    echo "0 - Create a new entry"
	cat .hosts | awk '{print $1}' | while read i; do echo $hostnum - $i; hostnum=$((hostnum+1)); done;
	echo
	read server
	if [ $server -eq 0 ]; then
		input
	else
		comm=$(sed -n ${server}p .hosts | awk '{$1=""; print $0}')
		$comm
	fi
}

function input {
	echo "What is the host nickname? (ONE WORD)"
	read hostname
	echo "What is the address? IP or FQDN"
	read host 
	echo "Port?"
	read port
	echo "User?"
	read user
	echo $hostname "ssh -p "$port $user"@"$host >> .hosts
	echo "Thanks for adding..."
	echo ""
	display
}

display