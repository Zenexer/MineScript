#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

TIMESTAMP='[^[:alnum:]]*[[:digit:]: -]\+'
sed "/^$TIMESTAMP"' \[INFO\] Sending Triang: /d;/^'"$TIMESTAMP"' \[WARNING\] Can'\''t keep up! Did the system time change, or is the server overloaded?\S*/d;/^'"$TIMESTAMP"' \[INFO\] \(Connection reset\|Reached end of stream\)\S*/d;s/\[[^m]*m//g; s/§§/¶/g; s/§[^§]//g; s/¶/§/g' "$@" || exit $?

