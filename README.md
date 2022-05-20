# curse me

Takes curseforge minecraft modpacks and installs them without the closed-source, glibc-dependent curseforge client.

### Dependencies

- p7zip
- jq
- bash
- curl
- java (well, duh)
- busybox OR gnu coreutils (tested on busybox ;3)

### Usage

1. Download a ZIP file from curseforge. This is hidden - curse really wants you to use their application. Go to Files -> Main File -> (click on the name) -> `Download` (NOT `Install`)
2. Clone this repository
3. Get an API key, and place it into the `token` file. You can do this legimately (I'll be here all day, we have time) or use `./getToken.sh` which extracts them from the CurseForge Client
4. Launch `parsePack.sh`; e.g. `./parsePack.sh "Above and Beyond-1.3.zip"`. This will download all of the mods.
5. If everything succeeds, a forge installer should pop up after a while. Fabric support is not available at this time.
6. Backup your `~/.minecraft` directory
7. Launch `./install.sh`
8. Profit..?

### TODO

- Fabric support
- GUI, if I have too much time
- better urlencoding if the current bodge breaks

### Contact the author (suggestions, DMCA, etc.)

I can be reached for any inquires via my e-mail: me (at) sdomi.pl. I also have a webpage - https://sdomi.pl/




gosh i love not agreeing to TOS
