#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"


# Stop Server {{{1
#
#

stop_server || exit $?

echo -n '' > "$MC_OUTPUT_LOG"

