#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/include/environment.sh" || exit $?

java ${MC_JAVA_ARGS[*]} ${MC_JAR_ARGS[*]} > "$MC_TEMP_FOLDER/output.log" 2>&1
EXIT_CODE=$?

# Prevent stalling
echo '' > "$MC_INPUT_STREAM"

exit $EXIT_CODE

