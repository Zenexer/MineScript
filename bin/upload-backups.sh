#!/bin/bash
# vim: ts=4 sw=4 sr sts=4 fdm=marker fmr={{{,}}} ff=unix fenc=utf-8 tw=80

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"
pushd "$MC_BACKUP_FOLDER" > /dev/null || exit $?


# S3cmd {{{1
#
#

if [ $# -lt 1 ]; then
	s3cmd put *.tar.xz "$MC_BACKUP_URI" || exit $?
else
	s3cmd put "$@" "$MC_BACKUP_URI" || exit $?
fi

