#!/bin/bash
rm -R build/curseme-w32/meow/
curl -L -o meow.tar.gz https://git.sakamoto.pl/domi/curseme/-/archive/launcher/curseme-launcher.tar.gz?path=launcher
tar xvf meow.tar.gz
mkdir -p build/curseme-w32/meow
mv curseme-launcher-launcher/launcher/* build/curseme-w32/meow/

styrene -o ./build ./curseme.cfg
