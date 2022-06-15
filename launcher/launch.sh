#!/bin/bash

function launch() {
	if [[ "$1" == '' ]]; then
		echo uh oh
		exit 1
	fi
	cd "$1"
	mkdir -p natives

	if [[ "$2" == '' ]]; then # for testing
		for i in $(find libraries/ | grep natives); do
			cp "$i" natives/
		done
		for i in natives/*.jar; do
			7z x -onatives/ $i -y
		done
	fi

	if [[ $(uname -o) == "Msys" ]]; then # winblows
		windows_fetch_java
	
		../jdk-18*/bin/java \
			-Xms128M \
			-Xmx4G \
			-Djava.library.path=natives/ \
			-cp $(find libraries/ -type f | tr '\n' ';')client.jar \
			$(jq -r '.mainClass' < manifest.json) \
			--gameDir . \
			--assetsDir assets \
			--version $1 \
			--accessToken "$(jq -r '.accessToken' < ../auth.json)" \
			--username "$(jq -r '.selectedProfile.name' < ../auth.json)" \
			--uuid "$(jq -r '.selectedProfile.id' < ../auth.json)"		
	else
		java \
			-Xms128M \
			-Xmx4G \
			-Djava.library.path=natives/ \
			-cp $(find libraries/ -type f | tr '\n' ':')client.jar \
			$(jq -r '.mainClass' < manifest.json) \
			--gameDir . \
			--assetsDir assets \
			--version $1 \
			--accessToken "$(jq -r '.accessToken' < ../auth.json)" \
			--username "$(jq -r '.selectedProfile.name' < ../auth.json)" \
			--uuid "$(jq -r '.selectedProfile.id' < ../auth.json)"
	fi
}

function windows_fetch_java() {
	pushd /meow
	if [[ $(ls jdk-18*) == '' ]]; then
		url="$(curl https://jdk.java.net/18/ | grep windows-x64 | grep -Poh 'https:.*?zip"' | sed 's/"//')"

		curl -o java.zip "$url"
		7z x java.zip
	fi
	popd
}
