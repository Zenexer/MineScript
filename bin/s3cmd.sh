#!/bin/bash
# vim: ts=4 sw=4 sr sts=4 fdm=marker fmr={{{,}}} ff=unix fenc=utf-8 tw=80

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"


# S3cmd {{{1
#
#

s3cmd "$@" || exit $?

