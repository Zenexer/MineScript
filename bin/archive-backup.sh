#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"
cd "$MC_BACKUP_FOLDER" || exit $?

function absolute_folder
{
	cd "$*" && pwd
}


# Tarball {{{1
#
#


TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
FILENAME="$MC_BACKUP_INSTANCE_FOLDER_NAME.$TIMESTAMP.tar.xz"
TARGET=(
	"`absolute_folder "$MC_BACKUP_INSTANCE_FOLDER_NAME"`"
	"`absolute_folder "$MC_BACKUP_INSTANCE_FOLDER_NAME.shell"`"
)

[ "$USER" == 'root' ] || fatal 1 'This command needs to be run as root, preferably through sudo.' || exit $?
#echo "Updating permissions on: ${TARGET[*]}"
#[ "$USER" == "$MC_UID" ] && reclaim "${TARGET[@]}" || sudo "$MC_SHELL_FOLDER/internal/reclaim.sh" "${TARGET[@]}" || exit $?

echo "Compressing to: $FILENAME"
tar --xz -cf "$FILENAME" "${TARGET[@]}" || exit $?


# Remove old files; restore structure {{{1
#
#

#echo 'Removing unarchived copy of backups.'
#rm -Rf --one-file-system "${TARGET[@]}" > /dev/null 2>&1 || rm -Rf "${TARGET[@]}" || exit $?

echo 'Done.  Remember to remove the old, uncompressed backups if the compression was successful.'

