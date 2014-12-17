#!/bin/bash

function printbar {
	printf "%s\n" "" "-----------------------------" ""
}

function display {
	hostnum=1
	printbar
    echo "0 - Create a new entry"
	cat $HOME/.hosts | awk '{print $1}' | while read i; do echo $hostnum - $i; hostnum=$((hostnum+1)); done;
	echo
	read -p "Where would you like to jump? (0): " server; server=${server:-0}
	printbar
	if [ $server -eq 0 ]; then
		input
	else
		comm=$(sed -n ${server}p $HOME/.hosts | awk '{$1=""; print $0}')
		$comm
	fi
}

function container {
	if [ ! -f $HOME/.hosts ]; then
		touch $HOME/.hosts
	fi
}

function input {
	read -p "Host nickname? ONE WORD: " hostname
	read -p "What's the address? IP or FQDN: " host
	read -p "Port? (22): " port; port=${port:-22} 
	read -p "User? (root): " user; user=${user:-root}
	echo $hostname "ssh -p "$port $user"@"$host >> $HOME/.hosts
	printbar
	rsacopy
	printbar
	echo "This host has been added."
	display
}

function rsacopy {
	echo "Would you like to copy your public key? (y/n)"
	read rsacp
	if [ $rsacp == "y" ]; then
		keycheck
		scp -P $port $HOME/.ssh/id_rsa.pub $user@$host:~/
		ssh -p $port $user@$host 'mkdir ~/.ssh' 2> /dev/null
		ssh -p $port $user@$host 'cat ~/id_rsa.pub >> ~/.ssh/authorized_keys && rm -f ~/id_rsa.pub'
	fi
}

function keycheck {
	if [ !	-f $HOME/.ssh/id_rsa.pub ]; then
		echo "It doesn't look like you've generated 'id_rsa.pub'."
		echo "Let me do that for you now."
		echo "Would you like to use a passphrase? (y/n)"
		mkdir $HOME/.ssh 2> /dev/null
		read passphrase
			if [ $passphrase == "y" ]; then
				ssh-keygen -t rsa -b 2048 -f $HOME/.ssh/id_rsa -q
			else
				ssh-keygen -t rsa -b 2048 -f $HOME/.ssh/id_rsa -q -N ""
			fi
	fi
}

container
display