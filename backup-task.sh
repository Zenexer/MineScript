#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/environment.sh"


# Run Backup {{{1
#
#

backup_meta

inject_clear && inject_line save-off && inject_line save-all

sleep 1m

backup_instance
EXIT_CODE=$?

inject_line save-on

exit $EXIT_CODE

