#!/bin/bash
if [[ $1 == '' ]]; then
	echo "usage: $0 <modpack.zip>"
	exit 1
fi
meow="$(realpath $1)"

mkdir packwrk; cd packwrk
7z -y x "$meow"

# fetch mods
if [[ ! -d mods ]]; then
	mkdir mods; cd mods
	cat ../manifest.json | jq -r '.files[] | "\(.projectID),\(.fileID)"' | while read line; do
		proj=${line/,*/}
		file=${line/*,/}

		url="$(curl -r -s -H "x-api-key: $(cat ../../token)" "https://api.curseforge.com/v1/mods/$proj/files/$file" | jq -r '.data.downloadUrl')"
		curl -s -O -J -L "$url" &
	done
	wait
	cd ..
fi

# fetch forge
modloader="$(cat manifest.json | jq -r '.minecraft | "\(.version),\(.modLoaders[] | select(.primary == true).id)"' | head -n1)"
if [[ $modloader == *"forge"* ]]; then
	mc=${modloader/,*/}
	forge=${modloader/*,forge-/}
	curl -L -O "https://maven.minecraftforge.net/net/minecraftforge/forge/$mc-$forge/forge-$mc-$forge-installer.jar"
	java -jar "forge-$mc-$forge-installer.jar"
else
	echo "mmmm my attention span is too short for fabric rn"
fi
