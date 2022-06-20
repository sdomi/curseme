#!/bin/bash
if [[ -f token ]]; then
	echo "The token file already exists. Skipping..."
	exit 0
fi

## slowwwwwww, but works
#mkdir -p wrk; cd wrk

#curl -L -O https://web.archive.org/web/20220519222137/https://curseforge.overwolf.com/downloads/curseforge-latest-linux.zip
#7z -y x curseforge-latest-linux.zip
#7z -y x *.AppImage
#grep -Poh 'cfCoreApiKey":".*?"' resources/app/dist/desktop/desktop.js | sed 's/.*://;s/"//g' > ../token

#cd ..; rm -R wrk

## I've been reversing the new API key storage for a few hours and found out that you didn't change the token
## you can rickroll me all you'd like, it's not like I'll care ;3

curl https://arch.b4k.co/vg/thread/388569358 | grep -Poh "and put .*? " | sed -E 's/.{8}//' > token
