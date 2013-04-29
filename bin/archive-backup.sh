#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh" || exit $?
cd "$MC_BACKUP_FOLDER" || exit $?


# Tarball {{{1
#
#


TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
FILENAME="$MC_BACKUP_INSTANCE_FOLDER_NAME.$TIMESTAMP.tar.xz"
TARGET=(
	"$MC_BACKUP_INSTANCE_FOLDER_NAME"
	"$MC_BACKUP_INSTANCE_FOLDER_NAME.shell"
)

echo "Updating permissions on: ${TARGET[*]}"
[ "$USER" == "$MC_UID" ] && reclaim "${TARGET[@]}" || sudo "$MC_SHELL_FOLDER/internal/reclaim.sh" "${TARGET[@]}" || exit $?

echo "Compressing to: $FILENAME"
tar --xz -cf "$FILENAME" "${TARGET[@]}" || exit $?


# Remove old files; restore structure {{{1
#
#

echo 'Removing unarchived copy of backups.'
#rm -Rf --one-file-system "${TARGET[@]}" > /dev/null 2>&1 || rm -Rf "${TARGET[@]}" || exit $?

# Restoration of environment {{{1
#
#

