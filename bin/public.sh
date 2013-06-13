#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

sed 's/\(\[[[:alnum:]_~]\+ -> [[:alnum:]_~]\+\]\) .*$/\1 ****/; s/\(\(\[ForgePlugin\] \[[^]]*\]\|\[PLAYER_COMMAND\] [[:alnum:]_~]\+:\|\[INFO\] [[:alnum:]_~]\+ issued server command:\) \/*\([mrtacpw]\|msg\|tell\|whisper\|mail send\|adminchat\|modchat\|partychat\|clanchat\|reply\|message\)\) .*$/\1 ****/; s/\(: \|\/\)\([0-2]\?[0-9]\+\.\)\{3\}[0-2]\?[0-9]\+\([:[:space:]]\|$\)/\1*.*.*.*\3/g' "$@" || exit $?

