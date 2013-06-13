#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"
cd "$MC_WORKDIR_FOLDER"

[ -e ~/.mc.sh ] && . ~/.mc.sh
[ -z "$MC_IGN" ] && MC_IGN="$USER"


# Run Loop {{{1
#
#

EXIT_CODE=0
while [ ! -e "$MC_TEMP_FOLDER/stop" ]; do
	read -erp '> ' INPUT || EXIT_CODE=$?

	INPUT="`echo "$(parse "$INPUT")" | sed 's/\(^[[:space:]]\+|[[:space:]]\+$\)//g; s/[[:space:]][[:space:]]*/ /g'`"
	ARGS=($INPUT)
	INPUT_LOWER="${INPUT,,}" || INPUT_LOWER="`echo -n "$INPUT" | awk '{print tolower($0)}'`" || INPUT_LOWER="$INPUT"

	case "$INPUT_LOWER" in
		'#'*)
			INPUT="ping [$MC_IGN] `echo "$INPUT" | sed 's/^#\+ *//'`"
			;;

		"'"*)
			INPUT="say [$MC_IGN] `echo "$INPUT" | sed 's/^'"'"'\+ *//'`"
			;;

		'say '*|'r '*|'reply '*|'ping '*)
			INPUT="${INPUT/ / [$MC_IGN] }"
			;;

		'm '*|'w '*|'t '*|'msg '*|'whisper '*|'tell '*)
			INPUT="${ARGS[*]:0:2} [$MC_IGN] ${ARGS[*]:2}"
			;;

		':'*)
			case "${INPUT_LOWER:1}" in
				'nick '*)
					OLD_IGN="$MC_IGN"
					NEW_MC_IGN="${INPUT/^.* }"
					
					if [ -z "$NEW_MC_IGN" ]; then
						echo $'\e[31mYour nickname cannot be blank.\e[m'
						continue
					fi

					MC_IGN="$MC_IGN"
					echo $'\e[32m'"Nickname changed to: $MC_IGN"$'\e[m'
					INPUT="say Console:$OLD_IGN is now known as Console:$MC_IGN"
					;;

				stop)
					stop_server || echo $'\e[31mError attempting to stop server.\e[m'
					continue
					;;

				*)
					echo $'\e[31mUnknown metacommand.\e[m' >&2
					continue
					;;
			esac
			;;
	esac

	input "$INPUT" || EXIT_CODE=$?
done

exit $EXIT_CODE

