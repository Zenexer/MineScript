#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/environment.sh"


# Run Backup {{{1
#
#

backup_shell 
EXIT_CODES[0]=$?

backup_instance
EXIT_CODES[1]=$?

for i in "$EXIT_CODES"; do
	(( $i )) || exit $i
done

