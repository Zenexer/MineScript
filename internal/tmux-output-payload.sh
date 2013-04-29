#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"

# Run {{{!
#
#

tail -f "$MC_TEMP_FOLDER/output.log" || exit $?

