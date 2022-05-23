#!/bin/bash

function launch() {
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
	
	/usr/lib/jvm/java-8-openjdk/bin/java \
		-Xms128M \
		-Xmx1G \
		-Djava.library.path=natives/ \
		-cp $(find libraries/ -type f | tr '\n' ':'):client.jar \
		$(jq -r '.mainClass' < manifest.json) \
		--gameDir "$(realpath .)" \
		--assetsDir "$(realpath .)/assets" \
		--version $1 \
		--accessToken "$(jq -r '.accessToken' < ../auth.json)" \
		--username "$(jq -r '.selectedProfile.name' < ../auth.json)" \
		--uuid "$(jq -r '.selectedProfile.id' < ../auth.json)"
}
