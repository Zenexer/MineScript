#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/environment.sh"
cd "$MC_WORKDIR_FOLDER"


# Cleanup {{{1
#
#

[ -e "$MC_TEMP_FOLDER/stop" ] && rm -f "$MC_TEMP_FOLDER/stop"


# Run Loop {{{1
#
#

EXIT_CODE=0
while [ ! -e "$MC_TEMP_FOLDER/stop" ]; do
	echo $'\e[32m'"Starting server. Working directory: $PWD"$'\e[0m'
	tail -f "$MC_INPUT_STREAM" | java ${MC_JAVA_ARGS[*]} ${MC_JAR_ARGS[*]}
	EXIT_CODE=$?
	echo $'\e[31mServer stopped.\e[0m'

	[ -e "$MC_TEMP_FOLDER/stop" ] && break
	sleep $MC_CONFIG_RESTART_DELAY
done

exit $EXIT_CODE

