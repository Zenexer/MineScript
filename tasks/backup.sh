#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"


# Run Backup {{{1
#
#

EXIT_CODE=0
backup_shell || EXIT_CODE=$?

# Prevent overlap with save task.
[ "$1" == 'now' ] || sleep 1m

backup_instance || EXIT_CODE=$?

case $EXIT_CODE in
	0)
		output $'\e[32mBackup successful.\e[m'
		say '&aBackup successful.'
		;;

	*)
		output $'\e[31mBackup failed!\e[m'
		say "&cBackup failed!  Contact Zenexer.  Error code: &7$EXIT_CODE"
		;;
esac

exit $EXIT_CODE

