#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"

# Run {{{1
#
#

TIMESTAMP='[^[:alnum:]]*[[:digit:]:]\+'
tail -f "$MC_TEMP_FOLDER/output.log" | stdbuf -o0 sed "/^$TIMESTAMP"' \[INFO\] Sending Triang: /d;/^'"$TIMESTAMP"' \[WARNING\] Can'\''t keep up! Did the system time change, or is the server overloaded?\S*/d;/^'"$TIMESTAMP"' \[INFO\] \(Connection reset\|Reached end of stream\)\S*/d' || exit $?

