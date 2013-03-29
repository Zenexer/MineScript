#!/bin/bash
# vim: ts=4 sw=4 sr sts=4 fdm=marker fmr={{{,}}} ff=unix fenc=utf-8 tw=80

# Advanced stuff.  Don't touch it unless you know what you are doing.
MC_CONFIG_INSTANCE="$MC_SHELL_FOLDER_NAME"
MC_CONFIG_INSTANCE_FOLDER_NAME="$MC_CONFIG_INSTANCE"
MC_CONFIG_BACKUP_INSTANCE_FOLDER_NAME="$MC_CONFIG_INSTANCE"

# The username and group under which the server will run.
MC_CONFIG_UID='mc'

# The filename of the server JAR, case-sensitive.  This should be in the
# live/[instance]/jar folder.
MC_CONFIG_JAR='craftbukkit.jar'

# The minimum amount of memory that Java will use.  Suffix with M for megabytes
# or G for gigabytes.  Decimals do not work.
MC_CONFIG_MIN_STACK='1G'

# The maximum amount of memory that Java will use.  Don't make it much higher
# than your server tends to require; Java will expand to as much space as you
# give it in a rather inefficient process.
MC_CONFIG_MAX_STACK='5632M'

# Any additional arguments to pass to the 'java' executable.  You might want to
# try some garbage collection shenanigans here.
MC_CONFIG_ADDITIONAL_JAVA_ARGS=''

# MineScript will automatically choose the right arguments based on the
# framework that you are using.  The chart below determines which value you
# should use.
# 
# FRAMEWORK			VERSION		VALUE
# CraftBukkit		recent		bukkit
# CraftBukkit		old			bukkit-old
# CraftBukkit		very old	vanilla
# Tekkit			1.2.5		tekkit
# Forge				>1.2.5		forge
# Vanilla			*			vanilla
# Spigot			*			bukkit
# Other				*			other
MC_CONFIG_FRAMEWORK='bukkit'

# Each instance has its own socket, so this does not need to be unique between
# instances.  Mostly for decoration.
MC_CONFIG_TMUX_SESSION='minecraft'

# The name that appears on the status bar in tmux.  Mostly for decoration.
MC_CONFIG_TMUX_WINDOW="$MC_CONFIG_INSTANCE"

# The height, in lines, of the input area.  The editor will consume some of
# these lines for status bars, etc.  You can, of course, scroll.
MC_CONFIG_TMUX_INPUT_HEIGHT=3

# Wait time, in seconds, before the server is restarted after it is stopped.  To
# bypass this and completely shut down the server until you manually restart it,
# use the stop-instance.sh script, then exit from the input text editor.
MC_CONFIG_RESTART_DELAY=3

# This is where you should put your changes to this default configuration.
[ -f "$MC_SHELL_FOLDER/configuration-local.sh" ] && . "$MC_SHELL_FOLDER/configuration-local.sh"

