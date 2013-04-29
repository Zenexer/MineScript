#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"
cd "$MC_WORKDIR_FOLDER"


# Run Loop {{{1
#
#

EXIT_CODE=0
while [ ! -e "$MC_TEMP_FOLDER/stop" ]; do
	read -erp '> ' INPUT || EXIT_CODE=$?

	case "$INPUT" in
		[#]*)
			continue
			;;

		[Ss][Aa][Yy]' '*)
			[ -e ~/.mc.sh ] && . ~/.mc.sh
			[ -z $MC_IGN ] && MC_IGN="$USER"
			INPUT="say [$MC_IGN] ${INPUT:4}"
			;;
	esac

	inject_line "$INPUT" || EXIT_CODE=$?
done

exit $EXIT_CODE

