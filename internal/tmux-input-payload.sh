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

	INPUT_LOWER="${INPUT,,}" || INPUT_LOWER="`echo -n "$INPUT" | awk '{print tolower($0)}'`" || INPUT_LOWER="$INPUT"

	case "$INPUT_LOWER" in
		'#'*)
			continue
			;;

		'say '*)
			[ -e ~/.mc.sh ] && . ~/.mc.sh
			[ -z "$MC_IGN" ] && MC_IGN="$USER"
			INPUT="say [$MC_IGN] ${INPUT:4}"
			;;

		':'*)
			case "${INPUT_LOWER:1}" in
				'nick '[^\ ]*)
					MC_IGN="${INPUT:6}"
					echo $'\e[32m'"Nickname changed to: $MC_IGN"$'\e[m'
					;;

				*)
					echo $'\e[31mUnknown metacommand.\e[m' >&2
					;;
			esac
			continue
			;;
	esac

	inject_line "$INPUT" || EXIT_CODE=$?
done

exit $EXIT_CODE

