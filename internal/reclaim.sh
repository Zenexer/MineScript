#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../environment.sh"


# Check Arguments {{{1
#
#

if [ $# -lt 1 ]; then
	echo -e "\e[31mSyntax: reclaim.sh file [file ...]\e[0m" >&2
	exit 1
fi


# Reclaim {{{1
#
#

reclaim "$@"
exit $?

