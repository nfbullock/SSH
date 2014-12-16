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

function container {
	if [ ! -f .hosts ]; then
		touch .hosts
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
	rsacopy
	echo "Thanks for adding..."
	echo ""
	display
}

function rsacopy {
	echo "Would you like to copy your public key? (y/n)"
	read rsacp
	if [ $rsacp == "y" ]; then
		keycheck
		scp -P $port ~/.ssh/id_rsa.pub $user@$host:~/
		ssh -p $port $user@$host 'mkdir .ssh 2>&1 1> /dev/null'
		ssh -p $port $user@$host 'cat ~/id_rsa.pub >> ~/.ssh/authorized_keys && rm -f ~/id_rsa.pub'
	fi
}

function keycheck {
	if [ !	-f ~/.ssh/id_rsa.pub ]; then
		echo "It doesn't look like you've generated 'id_rsa.pub'."
		echo "Let me do that for you now."
		echo "Would you like to use a passphrase? (y/n)"
		mkdir ~/.ssh
		read passphrase
			if [ $passphrase == "y" ]; then
				ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -q
			else
				ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -q -N ""
			fi
	fi
}

container
display