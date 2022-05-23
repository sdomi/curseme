#!/bin/bash

function fetch_manifest() {
	if [[ ! -f version_manifest.json ]]; then
		curl https://launchermeta.mojang.com/mc/game/version_manifest.json -O
	fi
}

function list_versions() {
	fetch_manifest
	
	jq -r '.versions[] | "\(.id)"' < version_manifest.json
}

function fetch_version() {
	fetch_manifest

	local url=$(jq -r '.versions[] | "\(.id),\(.url)"' < version_manifest.json | grep -P "^$1," | awk -F, '{print $2}')
	if [[ "$url" == '' ]]; then
		echo "Bad version?"
		return 1
	fi

	mkdir meow; cd meow
	curl -O "$url"

	mew="$(jq -r '.libraries[].downloads | if .classifiers then select(.classifiers["natives-linux"]) | .classifiers["natives-linux"] else .artifact end | "\(.url) \(.path)"' < $(basename "$url"))"

	IFS=$'\n'
	for i in $mew; do
		url=$(awk '{print $1}' <<< "$i")
		path=$(awk '{print $2}' <<< "$i")
		mkdir -p $(dirname "$path")
		curl -o "$path" "$url"
	done
	
	cd ..
}
