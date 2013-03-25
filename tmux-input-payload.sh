#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/environment.sh"
cd "$MC_WORKDIR_FOLDER"


# Run Loop {{{1
#
#

EXIT_CODE=0
while [ ! -e "$MC_TEMP_FOLDER/stop" ]; do
	if [ -f "$MC_TEMP_FOLDER/input.template" ]; then
		cp "$MC_TEMP_FOLDER/input.template" "$MC_TEMP_FOLDER/input"
	else
		echo -n "" > "$MC_TEMP_FOLDER/input"
	fi

	vim -i "$MC_TEMP_FOLDER/viminfo" -u "$MC_SHELL_FOLDER/etc/vimrc.vim" --noplugin --literal -- "$MC_TEMP_FOLDER/input"

	inject_line `cat "$MC_TEMP_FOLDER/input"`
done

exit $EXIT_CODE

