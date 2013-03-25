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

inject_line 'save-off' || exit $?
inject_line 'save-all' || exit $?

sleep 1m

backup_instance
exit $?

