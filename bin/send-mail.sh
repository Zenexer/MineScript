#!/bin/bash
# vim: fdm=marker fmr={{{,}}} fenc=utf-8

# Environment {{{1
#
#

. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../include/environment.sh"
cd "$MC_PLUGINS_FOLDER/Essentials/userdata" || fatal $? 'The Bukkit plugin "Essentials" is required to send mail to all users.'


# Argument Verification {{{1
#
#

if [ $# -lt 2 ]; then
	fatal 1 "Usage: $0 sender message	Sends a message to all users as if from the specified sender."
fi


# Send Mail {{{1
#
#

MESSAGE="$1: ${*:2}"
LINE="- '${MESSAGE/"'"/"''"}'"
LINE="${LINE/&/§}"

for i in *.yml; do
	if grep -q '^mail:' "$i"; then
		sed -e s/'^mail:\s*\(\[\s*\]\s*\)\?$'/"mail:\n${LINE/'/'/'\/'}"/ "$i" > "$i.sed"
		mv -f "$i.sed" "$i"
	else
		echo 'mail:' >> "$i"
		echo "$LINE" >> "$i"
	fi
done

