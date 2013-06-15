#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"
pushd "$MC_BACKUP_FOLDER" &> /dev/null || exit $?

[ "$USER" == 'root' ] || fatal 1 'This command needs to be run as root, preferably through sudo.' || exit $?

function absolute_folder
{
	cd "$*" && pwd
}


# Tarball {{{1
#
#


TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
FILENAME="archive/$MC_BACKUP_INSTANCE_FOLDER_NAME.$TIMESTAMP.tar.xz"
TARGET=(
	"`absolute_folder "$MC_BACKUP_INSTANCE_FOLDER_NAME"`"
	"`absolute_folder "$MC_BACKUP_INSTANCE_FOLDER_NAME.shell"`"
)
FOLDER="$MC_BACKUP_INSTANCE_FOLDER_NAME.archive"

#echo "Updating permissions on: ${TARGET[*]}"
#[ "$USER" == "$MC_UID" ] && reclaim "${TARGET[@]}" || sudo "$MC_SHELL_FOLDER/internal/reclaim.sh" "${TARGET[@]}" || exit $?

if [ ! -d "$FOLDER" ]; then
	mkdir "$FOLDER" || exit $?
	mv "${TARGET[@]}" "$FOLDER" || exit $?
	mkdir "${TARGET[@]}"
	reclaim "${TARGET[@]}"
fi

if [ ! -d 'archive' ]; then
	mkdir 'archive' || exit $?
	reclaim 'archive'
fi

echo "Compressing to: $FILENAME"
if [ $# -gt 0 ]; then
	tar --xz -cf "$FILENAME" "$FOLDER" &
	PID=$!
	echo "PID: $PID" >&2
	sleep 1s
	cpulimit -p $PID -l "$1" "${@:2}"
	wait $PID &> /dev/null
else
	tar --xz -cf "$FILENAME" "$FOLDER" || exit $?
fi

echo 'Done.  Remember to remove the old, uncompressed backups if the compression was successful.  Otherwise, the next archive attempt will reuse them and ignore any new files, assuming that the previous archive was unsuccessful.' >&2

