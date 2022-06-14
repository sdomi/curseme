#!/bin/bash
# helper.sh - sources everything and tries to refresh the token
cd /meow

source auth.sh
source ms_auth.sh
source launch.sh
source version.sh

function _login() {
	read -p "E-Mail: " login
	read -s -p "Password: " pass
	_login "$login" "$pass"

	cat auth.json
}

echo "Welcome to CurseMe (WIP)!"
if [[ -f auth.json ]]; then
	refresh
else
	echo -e 'This looks like your first launch. Start with logging in by executing `_login` or `ms_login` (i will rename those later)'
fi

PS1='CurseMe$ '
echo "Available (user-facing) commands:

list_versions           - well...
fetch_version <version> - downloads a specific version

launch <version>        - launches a previously downloaded version

_login                  - classic Mojang login
ms_login                - microsoft login 

Have fun!"
