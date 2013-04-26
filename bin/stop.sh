#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../environment.sh" || exit $?


# Stop Server {{{1
#
#

stop_server || exit $?

