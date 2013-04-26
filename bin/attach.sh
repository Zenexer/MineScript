#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../environment.sh" || exit $?


# Start Server In Background {{{1
#
#

tmux_attach || exit $?
