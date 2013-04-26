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

sleep 1m

backup_instance || EXIT_CODE=$?

exit $EXIT_CODE

