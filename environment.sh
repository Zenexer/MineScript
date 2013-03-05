#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Functions {{{1
#
#

function error # {{{2
{
	echo $'\e[31m'"$@"$'\e[0m' >&2
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
	
	error "\$1: $1"
	error "\$2: $2"
	return $EXIT_CODE
}

function send_tmux # {{{2
{
	if [ "`whoami`" == "$MC_UID" ]; then
		tmux -S "$MC_TMUX_SOCKET" $* || return $?
	else
		sudo su -c "tmux -S '$MC_TMUX_SOCKET' $* || exit $?" $MC_UID || return $?
	fi
}

function tmux_attach # {{{2
{
	send_tmux attach-session $@ -t "$MC_TMUX_SESSION" || return $?
}

function inject_keys # {{{2
{
	send_tmux send-keys -t "$MC_TMUX_SESSION:$MC_TMUX_WINDOW" $@ || return $?
}

function inject_clear # {{{2
{
	inject_line Home '#' Enter || return $?
}

function inject_line # {{{2
{
	inject_keys "$@" Enter || return $?
}

function start_server # {{{2
{
	if [[ "`send_tmux has-session -t "$MC_TMUX_SESSION" 2>&1`" =~ ".*failed to connect to server.*" ]]; then
		if ! send_tmux new-window -n "$MC_TMUX_WINDOW" -t "$MC_TMUX_SESSION:0" "$MC_TMUX_SHELL_COMMAND"; then
			error 'The server is already running.'
			return 1
		fi
	elif ! send_tmux new-session -d -n "$MC_TMUX_WINDOW" -s "$MC_TMUX_SESSION" "$MC_TMUX_SHELL_COMMAND"; then
		error 'Failed to create new session.'
		return 1
	fi
}

function stop_server # {{{2
{
	touch "$MC_TEMP_FOLDER/stop"

	inject_clear || return $?
	inject_line 'save-off' || return $?
	inject_line 'save-all' || return $?
	inject_line 'stop' || return $?
}

function backup_instance # {{{2
{
	rdiff-backup "$MC_INSTANCE_FOLDER" "$MC_BACKUP_INSTANCE_FOLDER" >> "$MC_BACKUP_LOG_FOLDER/$MC_INSTANCE.log" 2>&1 || return $?
}

function backup_meta # {{{2
{
	rdiff-backup "$MC_SHELL_FOLDER" "$MC_BACKUP_FOLDER/$MC_SHELL_FOLDER_NAME" >> "$MC_BACKUP_LOG_FOLDER/meta.$MC_SHELL_FOLDER_NAME.log" 2>&1 || return $?
}


# Initialization Variables {{{1
#
#

MC_FOLDER="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && cd .. && pwd)"
MC_SHELL_FOLDER_NAME='shell'
MC_SHELL_FOLDER="`get_folder "$MC_FOLDER" "$MC_SHELL_FOLDER_NAME" || exit $?`" || exit 191


# Configuration {{{1
#
#

source "$MC_SHELL_FOLDER/configuration.sh"


# Variables {{{1
#
#

# Instance {{{2
MC_INSTANCE="$MC_CONFIG_INSTANCE"
MC_UID="$MC_CONFIG_UID"

# Folders {{{2
# Next available error code (double check that it's available): 114
MC_LIVE_FOLDER="`get_folder "$MC_FOLDER" 'live' || exit $?`" || exit 113
MC_INSTANCE_FOLDER_NAME="$MC_CONFIG_INSTANCE_FOLDER_NAME"
MC_INSTANCE_FOLDER="`get_folder "$MC_LIVE_FOLDER" "$MC_INSTANCE_FOLDER_NAME" || exit $?`" || exit 102
MC_BACKUP_FOLDER="`get_folder "$MC_FOLDER" 'backup' || exit $?`" || exit 103
MC_BACKUP_INSTANCE_FOLDER_NAME="$MC_CONFIG_BACKUP_INSTANCE_FOLDER_NAME"
MC_BACKUP_INSTANCE_FOLDER="`get_folder "$MC_BACKUP_FOLDER" "$MC_BACKUP_INSTANCE_FOLDER_NAME" || exit $?`" || exit 112
MC_PLUGINS_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'plugins' || exit $?`" || exit 104
MC_WORLDS_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'worlds' || exit $?`" || exit 105
MC_WORKDIR_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'workdir' || exit $?`" || exit 106
MC_CONFIG_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'config' || exit $?`" || exit 107
MC_JAR_FOLDER="`get_folder "$MC_INSTANCE_FOLDER" 'jar' || exit $?`" || exit 108
MC_TEMP_FOLDER="`get_folder "$MC_FOLDER" 'tmp' || exit $?`" || exit 109
MC_LOG_FOLDER="`get_folder "$MC_FOLDER" 'log' || exit $?`" || exit 110
MC_BACKUP_LOG_FOLDER="`get_folder "$MC_LOG_FOLDER" 'backup' || exit $?`" || exit 111

# Arguments {{{2
MC_CRAFTBUKKIT_ARGS=(
	"--config $MC_CONFIG_FOLDER/server.properties"
	"--plugins $MC_PLUGINS_FOLDER"
	"--universe $MC_WORLDS_FOLDER"
	"--log-count 1"
	"--log-append true"
	"--bukkit-settings $MC_CONFIG_FOLDER/bukkit.yml"
)

MC_JAVA_ARGS=(
	"-server"
	"-Xms$MC_CONFIG_MIN_STACK"
	"-Xmx$MC_CONFIG_MAX_STACK"
	"-jar $MC_CONFIG_JAR"
)

# tmux {{{2
MC_TMUX_SESSION="$MC_CONFIG_TMUX_SESSION"
MC_TMUX_SOCKET="$MC_TEMP_FOLDER/tmux.socket"
MC_TMUX_WINDOW="$MC_CONFIG_TMUX_WINDOW"
MC_TMUX_SHELL_COMMAND="$MC_SHELL_FOLDER/tmux-payload.sh"


# Preparation {{{1
#
#

[ ! -e "$MC_WORKDIR_FOLDER/$MC_CONFIG_JAR" ] && ln -s "$MC_JAR_FOLDER/$MC_CONFIG_JAR" "$MC_WORKDIR_FOLDER/$MC_CONFIG_JAR"
