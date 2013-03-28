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
	read -erp '> ' INPUT

	case "$INPUT" in
		'#'*)
			continue
			;;

		# Have to make different windows for different users first.
		#'say '*)
		#	[ -e ~/.mc.sh ] && . ~/.mc.sh
		#	[ -z $MC_IGN ] && MC_IGN="$USER"
		#	INPUT="say [$MC_IGN] ${INPUT:4}"
		#	;;
	esac

	inject_line "$INPUT"
done

exit $EXIT_CODE

