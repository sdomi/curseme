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

	mkdir -p $1; cd $1
	curl -o manifest.json "$url"
	curl -o client.jar "$(jq -r '.downloads.client.url' < manifest.json)"
	curl -o assets.json "$(jq -r '.assetIndex.url' < manifest.json)"


	mew="$(jq -r '.libraries[].downloads | if .classifiers then select(.classifiers["natives-linux"]) | .classifiers["natives-linux"] else .artifact end | "\(.url) \(.path)"' < manifest.json)"

	IFS=$'\n'
	mkdir -p libraries; cd libraries
	for i in $mew; do
		_url=$(awk '{print $1}' <<< "$i")
		path=$(awk '{print $2}' <<< "$i")
		mkdir -p $(dirname "$path")
		curl -o "$path" "$_url"
	done
	cd ..
	
	# assets
	mkdir -p assets; cd assets
	for i in $(jq -r '.objects | keys[] as $k | "\(.[$k].hash) \($k)"' < ../assets.json); do
		hash=$(awk '{print $1}' <<< "$i")
		hash_start=$(cut -c 1-2 <<< "$hash")
		path=$(awk '{print $2}' <<< "$i")
		mkdir -p $(dirname "$path")
		curl -o $path "http://resources.download.minecraft.net/$hash_start/$hash"
	done
	cd ..
	
	cd ..
	unset IFS
}
