#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/include/environment.sh"
cd "$MC_WORKDIR_FOLDER"

[ -e "$MC_TEMP_FOLDER/stop" ] && rm -f "$MC_TEMP_FOLDER/stop"


# Run Loop {{{1
#
#

EXIT_CODE=0
while [ ! -e "$MC_TEMP_FOLDER/stop" ]; do
	echo $'\e[32m'"Starting server. Working directory: $PWD"$'\e[0m'
	tail -f "$MC_INPUT_STREAM" | "$MC_SHELL_FOLDER/internal/run-java.sh"
	EXIT_CODE=$?
	echo $'\e[31mServer stopped.\e[0m'

	[ -e "$MC_TEMP_FOLDER/stop" ] && break
	sleep $MC_CONFIG_RESTART_DELAY
done

exit $EXIT_CODE

