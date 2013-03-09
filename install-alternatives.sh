#!/bin/bash

function install_alternative
{
	update-alternatives --install "/usr/bin/$i" "$i" "`pwd`/$i" 10002
	return $?
}

for i in $@; do
	if [ -x "$i" ]; then
		install_alternative "$i" || echo $'\e[31m'"Failed to install $i  (Error code: $?)."$'\e[0m'
	fi
done

