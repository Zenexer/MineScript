#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

MC_CONFIG_INSTANCE="$MC_SHELL_FOLDER_NAME"
MC_CONFIG_INSTANCE_FOLDER_NAME="$MC_CONFIG_INSTANCE"
MC_CONFIG_BACKUP_INSTANCE_FOLDER_NAME="$MC_CONFIG_INSTANCE"

MC_CONFIG_UID='mc'
MC_CONFIG_JAR='tekkit.jar'
MC_CONFIG_MIN_STACK='1G'
MC_CONFIG_MAX_STACK='4608M'
MC_CONFIG_ADDITIONAL_JAVA_ARGS=''

# CraftBukkit		recent		bukkit
# CraftBukkit		old			bukkit-old
# CraftBukkit		very old	vanilla
# Tekkit			1.2.5		tekkit
# Forge				>1.2.5		forge
# Vanilla			*			vanilla
# Spigot			*			bukkit
MC_CONFIG_FRAMEWORK='tekkit'

MC_CONFIG_TMUX_SESSION='minecraft'
MC_CONFIG_TMUX_WINDOW="$MC_CONFIG_INSTANCE"
MC_CONFIG_TMUX_INPUT_HEIGHT=10

MC_CONFIG_RESTART_DELAY=3

