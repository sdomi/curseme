#!/bin/bash
if [[ -f token ]]; then
	echo "The token file already exists. Skipping..."
	exit 0
fi

mkdir -p wrk; cd wrk

curl -O https://curseforge.overwolf.com/downloads/curseforge-latest-linux.zip
7z -y x curseforge-latest-linux.zip
7z -y x *.AppImage
grep -Poh 'cfCoreApiKey":".*?"' resources/app/dist/desktop/desktop.js | sed 's/.*://;s/"//g' > ../token

cd ..; rm -R wrk
