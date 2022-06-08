#!/bin/bash

packdir=packwrk
cachedir=.cache
lockfile=.lock

set -eo pipefail

if [[ $1 == '' ]]; then
	echo "usage: $0 <modpack.zip>"
	exit 1
fi
srcfile="$(realpath "$1")"
[[ -f "$srcfile" ]] || { echo 2>&1 "Modpack archive \"$srcfile\" not found"; exit 1; }

tokenfile="$(dirname "$(realpath "$0")")/token"
if [[ ! -f "$tokenfile" ]]; then
	echo 2>&1 "No tokenfile found. Try running ./getToken.sh..?"
	exit 1
fi
token="$(cat "$tokenfile")"

packname="$(basename -s .zip "$srcfile")"

rm -fr "$packdir"
mkdir -p "$packdir"
7z -bb0 -bso0 -bsp0 -y -o"$packdir" x "$srcfile"

manifest="$packdir/manifest.json"
destindex="$packdir/modrinth.index.json"
loaderver="$(jq -r '.minecraft.modLoaders[] | select(.primary==true).id' "$manifest")"

cat > "$destindex" <<EOF
{
	"formatVersion": 1,
	"game": "minecraft",
	"versionId": "$(jq -r '.version' $manifest)",
	"name": "$(jq -r '.name' $manifest)",
	"summary": "by $(jq -r '.author' $manifest)",
	"dependencies": {
		"minecraft": "$(jq -r .minecraft.version "$manifest")",
		"${loaderver/-*/}": "${loaderver/*-/}"
	},
	"files": [

EOF


mkdir -p "$cachedir"

touch "$lockfile"
first=1
while read line; do
	proj=${line/,*/}
	file=${line/*,/}

	(

		cachefile="$cachedir/$proj.$file.json"
		curl -s -H "x-api-key: $token" -o "$cachefile" -z "$cachefile" "https://api.curseforge.com/v1/mods/$proj/files/$file"

		filename="$(jq -r .data.fileName "$cachefile")"

		if [[ $filename == *.zip ]] ; then
			filename="resourcepacks/$filename"
		elif [[ $filename == *.jar ]] ; then
			filename="mods/$filename"
		else
			filename="$filename"
		fi

		echo $filename
 
		exec 200>"$lockfile" || exit 1
		flock 200 || { echo "ERROR: flock() failed." >&2; exit 1; }

		[[ $first ]] || echo , >> "$destindex"
		cat >> "$destindex" <<EOF
			{
				"path": "$filename",
				"hashes": { "sha1": "$(jq -r '.data.hashes[] | select(.algo==1).value' "$cachefile")" },
				"env": { "client": "required" },
				"downloads": [ "$(jq -r .data.downloadUrl "$cachefile")" ],
				"fileSize": $(jq -r .data.fileLength "$cachefile")
			}
EOF

	) &

	if [[ "$first" ]] ; then
		wait
		first=
	fi

done < <(jq -r '.files[] | "\(.projectID),\(.fileID)"' $packdir/manifest.json)

wait

rm -f "$lockfile"

cat >> "$destindex" <<EOF

	]
}
EOF


mv -f $packdir/manifest.json $packdir/manifest.json.bak

( cd "$packdir" ; 7z -bb0 -bso0 -bsp0 a "../$packname.zip" . )

mv -f "$packname.zip" "$packname.mrpack"

rm -fr "$packdir"