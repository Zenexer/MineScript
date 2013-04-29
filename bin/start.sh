#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"


# Start Server In Background {{{1
#
#

start_server || fatal $? 'Failed to start server.'

# Attach To tmux {{{1
#
#

tmux_attach || fatal $? 'Failed to attach to server.'

