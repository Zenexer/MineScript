#!/bin/bash

function install_alternative
{
	update-alternatives --install "/usr/bin/$1" "$1" "`pwd`/$1" 10002 || return $?
}

for i in $@; do
	if [ -x "$i" ]; then
		install_alternative "$i" || echo $'\e[31m'"Failed to install $i  (Error code: $?)."$'\e[0m'
	fi
done

