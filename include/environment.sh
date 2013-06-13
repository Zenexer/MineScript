#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8


# Functions {{{1
#
#

function error # {{{2
{
	echo $'\e[31m'"${*:2} [$1]"$'\e[m' >&2
	return $1
}

function fatal # {{{2
{
	error $1 "${*:2}" || return $?
}

function ensure_folder # {{{2
{
	if [ -e "$1" ]; then
		if [ ! -d "$1" ]; then
			mv "$1" "$1".file
			mkdir -p "$1" || return $?
		fi
	else
		mkdir -p "$1" || return $?
	fi

	[ -z "$2" ] && cd "$1"
}

function get_folder # {{{2
{
	ensure_folder "$1"
	EXIT_CODE=$?
	if ! (( $EXIT_CODE )); then
		ensure_folder "$2"
		EXIT_CODE=$?
		if ! (( $EXIT_CODE )); then
			pwd

			unset EXIT_CODE
			return 0
		fi
	fi
	
	fatal $EXIT_CODE "\$1: $1\n\$2: $2"
}

function send_tmux # {{{2
{
	tmux -S "$MC_TMUX_SOCKET" "$@" || return $?
}
export -f send_tmux

function send_tmux_server # {{{2
{
	if [ "$USER" == "$MC_UID" ]; then
		tmux -S "$MC_TMUX_SERVER_SOCKET" "$@" || return $?
	else
		sudo su -c "tmux -S '$MC_TMUX_SERVER_SOCKET' $*" "$MC_UID" || return $?
	fi
}
export -f send_tmux_server

function tmux_attach # {{{2
{
	send_tmux has-session -t "$MC_TMUX_SESSION" > /dev/null 2>&1 || start_client || fatal $? 'Failed to start client.'

	tmux_focus || fatal $? 'Failed to focus tmux window.'
	send_tmux attach-session -t "$MC_TMUX_SESSION" || fatal $? 'Failed to attach to tmux session.'
}
export -f tmux_attach

function inject_keys # {{{2
{
	send_tmux send-keys -t "$MC_TMUX_SESSION:$MC_TMUX_WINDOW.0" $@ || return $?
}
export -f inject_keys

function inject_line # {{{2 Deprecated
{
	input "$*" || return $?
}
export -f inject_line

function log_input # {{{2
{
	CODE=0

	#TIMESTAMP_SHORT="`date +'%H:%M:%S'` [CONSOLE]"
	#TIMESTAMP_LONG="`date +'%Y-%m-%d %H:%M:%S'` [CONSOLE]"
	TIMESTAMP_RFC="`date --rfc-3339=ns`"

	entry="$TIMESTAMP_RFC"$'\t'"`whoami`: $*"
	echo "$entry" >> "$MC_INPUT_LOG" || echo "$entry" | sudo bash -c "cat >> ${MC_INPUT_LOG//"'"/"'\"'\"'"}'" || CODE=$?

	# These have stream overlap issues.

	#entry="$TIMESTAMP_SHORT $*"
	#echo "$entry" >> "$MC_OUTPUT_LOG" || echo "$entry" | sudo bash -c "cat >> ${MC_OUTPUT_LOG//"'"/"'\"'\"'"}'" || CODE=$?

	#entry="$TIMESTAMP_LONG `whoami`: $*"
	#echo "$entry" >> "$MC_SERVER_LOG" || echo "$entry" | sudo bash -c "cat >> ${MC_SERVER_LOG//"'"/"'\"'\"'"}'" || CODE=$?

	return $CODE
}
export -f log_input

function input # {{{2
{
	if [ -e "$MC_INPUT_STREAM" ]; then
		log_input "$*"
		echo "$*" > "$MC_INPUT_STREAM" || echo "$*" | sudo bash -c "cat > '${MC_INPUT_STREAM//"'"/"'\"'\"'"}'" || return $?
	else
		return 1
	fi
}
export -f input

function output # {{{2
{
	if [ -e "$MC_OUTPUT_LOG" ]; then
		echo "$*" >> "$MC_OUTPUT_LOG" || echo "$*" | sudo bash -c "cat >> '${MC_OUTPUT_LOG//"'"/"'\"'\"'"}'" || return $?
	else
		return 1
	fi
}
export -f output

function parse # {{{2
{
	echo "$*" | sed 's/§/&/g; s/&\([[:digit:]a-fnkrol&]\)/§\1/gI; s/§§/&/g' || return $?
}
export -f parse

function command # {{{2
{
	input "$1" "`parse "${*:2}"`" || return $?
}
export -f command

function say # {{{2
{
	command 'say' "$*"
}
export -f say

function start_server # {{{2
{
	if send_tmux_server has-session -t "$MC_TMUX_SESSION" > /dev/null 2>&1; then
		fatal 1 'The server is already running.'
	else
		[ -e "$MC_INPUT_STREAM" ] && rm -f "$MC_INPUT_STREAM"

		if [ "$USER" == "$MC_UID" ]; then
			mkfifo "$MC_INPUT_STREAM" || error $? 'Could not make FIFO file for input stream.' || return $?
		else
			mkfifo "$MC_INPUT_STREAM" || error $? 'Could not make FIFO file for input stream.' || return $?
			sudo chown "$MC_UID:$MC_UID" "$MC_INPUT_STREAM" || error $? 'Could not set permissions on FIFO input stream.  Ensure that you have access to sudo without the need for a password.' || return $?
		fi

		send_tmux_server new-session -d -n "$MC_TMUX_WINDOW" -s "$MC_TMUX_SESSION" "$MC_TMUX_SHELL_COMMAND" || error $? 'Failed to create new session.' || return $?
	fi
}
export -f start_server

function start_client # {{{2
{
	if send_tmux has-session -t "$MC_TMUX_SESSION" > /dev/null 2>&1; then
		send_tmux new-window -n "$MC_TMUX_SESSION:$MC_TMUX_WINDOW" "$MC_TMUX_OUTPUT_SHELL_COMMAND" || fatal $? 'Failed to create new window.'
	else
		send_tmux new-session -d -n "$MC_TMUX_WINDOW" -s "$MC_TMUX_SESSION" "$MC_TMUX_OUTPUT_SHELL_COMMAND" || fatal $? 'Failed to create new session.'
	fi

	send_tmux split-window -t "$MC_TMUX_SESSION:$MC_TMUX_WINDOW.0" -l "$MC_CONFIG_TMUX_INPUT_HEIGHT" "$MC_TMUX_INPUT_SHELL_COMMAND" || return $?
}
export -f start_client

function tmux_focus # {{{2
{
	send_tmux select-pane $@ -t "$MC_TMUX_SESSION:$MC_TMUX_WINDOW.1" || return $?
	send_tmux select-window $@ -t "$MC_TMUX_SESSION:$MC_TMUX_WINDOW" || return $?
}
export -f tmux_focus

function stop_server # {{{2
{
	touch "$MC_TEMP_FOLDER/stop"

	inject_line 'save-off' || return $?
	inject_line 'save-all' || return $?
	inject_line 'stop' || return $?
}
export -f stop_server

function reclaim # {{{2
{
	sudo chown -R "$MC_UID:$MC_UID" "$@" || chown -R "$MC_UID:$MC_UID" "$@" || return $?

	ERR=0

	if [ "$USER" == "$MC_UID" -o "$USER" == 'root' ]; then
		for i in "$@"; do
			if [ -d "$i" ]; then
				for f in "$i"/**/*; do						# Necessary because argument list will be too long for sudo.
					chmod ug+rw "$f" || ERR=$?				# Files
				done
				for d in "$i"/**/; do
					chmod ug+rwx,g+s "$d" || ERR=$?			# Directories
				done
			elif [ -f "$i" ]; then
				chmod ug+rw "$i" || ERR=$?
			fi
		done
	else
		for i in "$@"; do
			if [ -d "$i" ]; then
				for f in "$i"/**/*; do						# Necessary because argument list will be too long for sudo.
					sudo chmod ug+rw "$f" || ERR=$?			# Files
				done
				for d in "$i"/**/; do
					sudo chmod ug+rwx,g+s "$d" || ERR=$?	# Directories
				done
			elif [ -f "$i" ]; then
				sudo chmod ug+rw "$i" || ERR=$?
			fi
		done
	fi

	return $ERR;
}
export -f reclaim

function backup_instance # {{{2
{
	ensure_folder "$MC_BACKUP_INSTANCE_FOLDER" || error $? 'Unable to ensure existence of instance backup folder.' || return $?
	reclaim "$MC_WORLDS_FOLDER" || error $? "Unable to set permissions on worlds folder.  Try giving the user '$USER' permission to use sudo without a password." || return $?
	rdiff-backup "$MC_INSTANCE_FOLDER" "$MC_BACKUP_INSTANCE_FOLDER" >> "$MC_BACKUP_LOG_FOLDER/$MC_INSTANCE.log" 2>&1 || error $? 'rdiff-backup failed.  See log file for details.' || return $?
}
export -f backup_instance

function backup_shell # {{{2
{
	ensure_folder "$MC_BACKUP_INSTANCE_FOLDER.shell" || error $? 'Unable to ensure existence of instance shell backup folder.' || return $?
	reclaim "$MC_SHELL_FOLDER" || error $? "Unable to set permissions on shell folder.  Try giving the user '$USER' permission to use sudo without a password." || return $?
	rdiff-backup "$MC_SHELL_FOLDER" "$MC_BACKUP_INSTANCE_FOLDER.shell" >> "$MC_BACKUP_LOG_FOLDER/$MC_INSTANCE.shell.log" 2>&1 || error $? 'rdiff-backup failed.  See log file for details.' || return $?
}
export -f backup_shell


# Initialization {{{1
#
#

MC_SHELL_FOLDER="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && cd .. && pwd)"
MC_SHELL_FOLDER_NAME="${MC_SHELL_FOLDER##*/}"
MC_FOLDER="$(cd "$(readlink -f "$(cd "$MC_SHELL_FOLDER" && cd .. && pwd)")" && pwd)"

cd "$MC_SHELL_FOLDER" || fatal $? "Cannot set $MC_SHELL_FOLDER as current directory."

shopt -s globstar || fatal $? 'Unable to set globstar shell option in bash.'


# Configuration {{{1
#
#

. "$MC_SHELL_FOLDER/include/configuration.sh"


# Variables {{{1
#
#

# Instance {{{2
export MC_INSTANCE="$MC_CONFIG_INSTANCE"
export MC_UID="$MC_CONFIG_UID"

# Folders {{{2
# Next available error code (double check that it's available): 117
MC_LIVE_FOLDER="`get_folder "$MC_FOLDER" 'live' || exit $?`" || exit 113
MC_INSTANCE_FOLDER_NAME="$MC_CONFIG_INSTANCE_FOLDER_NAME" || exit 114
MC_INSTANCE_FOLDER="`get_folder "$MC_LIVE_FOLDER" "$MC_INSTANCE_FOLDER_NAME" || exit $?`" || exit 102
MC_BACKUP_FOLDER="`get_folder "$MC_FOLDER" 'backup' || exit $?`" || exit 103
MC_BACKUP_INSTANCE_FOLDER_NAME="$MC_CONFIG_BACKUP_INSTANCE_FOLDER_NAME" || exit 115
MC_BACKUP_INSTANCE_FOLDER="`get_folder "$MC_BACKUP_FOLDER" "$MC_BACKUP_INSTANCE_FOLDER_NAME" || exit $?`" || exit 112
MC_PLUGINS_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'plugins' || exit $?`" || exit 104
MC_WORLDS_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'worlds' || exit $?`" || exit 105
MC_WORKDIR_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'workdir' || exit $?`" || exit 106
MC_CONFIG_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'config' || exit $?`" || exit 107
MC_JAR_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'jar' || exit $?`" || exit 108
MC_GLOBAL_TEMP_FOLDER="`get_folder "$MC_FOLDER" "tmp" || exit $?`" || exit 109
MC_TEMP_FOLDER="`get_folder "$MC_GLOBAL_TEMP_FOLDER" "$MC_CONFIG_INSTANCE_FOLDER_NAME" || exit $?`" || exit 109
MC_LOG_FOLDER="`get_folder "$MC_FOLDER" 'log' || exit $?`" || exit 110
MC_LOG_INSTANCE_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'log' || exit $?`" || exit 116
MC_BACKUP_LOG_FOLDER="`get_folder "$MC_LOG_FOLDER" 'backup' || exit $?`" || exit 111

# Streams, Devices, and Logs {{{2
MC_INPUT_STREAM="$MC_TEMP_FOLDER/input.stream"
MC_INPUT_LOG="$MC_LOG_INSTANCE_FOLDER/input.log"
MC_OUTPUT_LOG="$MC_TEMP_FOLDER/output.log"
MC_SERVER_LOG="$MC_LOG_INSTANCE_FOLDER/server.log"

# Arguments {{{2
case "$MC_CONFIG_FRAMEWORK" in
	bukkit)
		MC_JAR_ARGS=(
			"--config $MC_CONFIG_FOLDER/server.properties"
			"--plugins $MC_PLUGINS_FOLDER"
			"--universe $MC_WORLDS_FOLDER"
			"--log-count 1"
			"--log-append true"
			"--bukkit-settings $MC_CONFIG_FOLDER/bukkit.yml"
		)
		;;

	*)
		MC_JAR_ARGS=()
		;;
esac

MC_JAVA_ARGS=(
	"-server"
	"-Xms$MC_CONFIG_MIN_STACK"
	"-Xmx$MC_CONFIG_MAX_STACK"
	"$MC_CONFIG_ADDITIONAL_JAVA_ARGS"
	"-jar $MC_CONFIG_JAR"
)

# tmux {{{2
MC_TMUX_SESSION="$MC_CONFIG_TMUX_SESSION"
MC_TMUX_SOCKET="$MC_TEMP_FOLDER/tmux.$USER.socket"
MC_TMUX_SERVER_SOCKET="$MC_TEMP_FOLDER/tmux.socket"
MC_TMUX_WINDOW="$MC_CONFIG_TMUX_WINDOW"
MC_TMUX_SHELL_COMMAND="$MC_SHELL_FOLDER/internal/tmux-run-payload.sh"
MC_TMUX_INPUT_SHELL_COMMAND="$MC_SHELL_FOLDER/internal/tmux-input-payload.sh"
MC_TMUX_OUTPUT_SHELL_COMMAND="$MC_SHELL_FOLDER/internal/tmux-output-payload.sh"


# Preparation {{{1
#
#

[ ! -e "$MC_WORKDIR_FOLDER/$MC_CONFIG_JAR" ] && ln -s "$MC_JAR_FOLDER/$MC_CONFIG_JAR" "$MC_WORKDIR_FOLDER/$MC_CONFIG_JAR"
[ ! -e "$MC_LOG_FOLDER/$MC_INSTANCE" ] && mv "$MC_LOG_INSTANCE_FOLDER" "$MC_LOG_FOLDER/$MC_INSTANCE" && ln -s "$MC_LOG_FOLDER/$MC_INSTANCE" "$MC_LOG_INSTANCE_FOLDER"

