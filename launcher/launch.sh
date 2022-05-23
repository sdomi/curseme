#!/bin/bash

function launch() {
	cd "$1"
	mkdir -p natives

	for i in $(find libraries/ | grep natives); do
		cp "$i" natives/
	done
	for i in natives/*.jar; do
		7z x -onatives/ $i -y
	done
	
	java -Djava.library.path=natives/ -cp $(find libraries/ -type f | tr '\n' ':'):client.jar $(jq -r '.mainClass' < manifest.json)	
}
