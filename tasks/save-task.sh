#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"


# Run Save {{{1
#
#

inject_line 'save-off' || exit $?
inject_line 'save-all' || exit $?

