#!/bin/bash
if [[ $1 == '' ]]; then
	echo "usage: $0 <modpack.zip>"
	exit 1
fi
token="$(dirname "$(realpath $0)")/token"
meow="$(realpath $1)"

if [[ ! -f "$token" ]]; then
	echo "No tokenfile found. Try running ./getToken.sh..?"
	exit 1
fi

mkdir packwrk; cd packwrk
7z -y x "$meow"

# fetch mods
if [[ ! -d mods ]]; then
	mkdir mods; cd mods
	mods="$(cat ../manifest.json | jq -r '.files[] | "\(.projectID),\(.fileID)"')"
	echo "Downloading $(wc -l <<< "$mods") mods"
	while read line; do
		proj=${line/,*/}
		file=${line/*,/}

		url="$(curl -s -H "x-api-key: $(cat "$token")" \
				"https://api.curseforge.com/v1/mods/$proj/files/$file" \
				| jq -r '.data.downloadUrl')"
		url_fix="$(sed 's/\[/%5b/g;s/\]/%5d/g;'"s/'/%27/g;s/ /%20/g" <<< "$url")" #' handling for bad URLs
		curl -s -o "$(basename "$url")" -L "$url_fix" || echo "Failed to download $url" &
		printf "."
	done <<< "$mods"
	wait
	echo "Done"
	cd ..
fi

# fetch forge
modloader="$(cat manifest.json | jq -r '.minecraft | "\(.version),\(.modLoaders[] | select(.primary == true).id)"' | head -n1)"
if [[ $modloader == *"forge"* ]]; then
	mc=${modloader/,*/}
	forge=${modloader/*,forge-/}

	# handling for old forge binary names
	if [[ $(grep -Poh "(1\.10$|1\.9|1\.8|1\.7|1\.6|1\.5|1\.4|1\.3|1\.2|1\.1$)" <<< "$mc") == '' ]]; then	
		curl -L -O "https://maven.minecraftforge.net/net/minecraftforge/forge/$mc-$forge/forge-$mc-$forge-installer.jar"
		java -jar "forge-$mc-$forge-installer.jar"
	else
		curl -L -O "https://maven.minecraftforge.net/net/minecraftforge/forge/$mc-$forge-$mc/forge-$mc-$forge-$mc-installer.jar"
		java -jar "forge-$mc-$forge-$mc-installer.jar"
	fi
else
	echo "mmmm my attention span is too short for fabric rn"
fi
