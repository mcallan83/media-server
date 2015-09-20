# Media Server Installer

Bootstraps the installation of a complete media server with support for automatically downloading, managing, and streaming TV shows and movies.

This script has been tested with Ubuntu Server. Installed applications are available via web based control panels.

## Included Software

- [CouchPotato](https://couchpota.to/) Download movies automatically, easily and in the best quality as soon as they are available.
- [Deluge](http://deluge-torrent.org/) A lightweight BitTorrent client.
- [Jackett](https://github.com/zone117x/Jackett) A Torznab\TorrentPotato API server that enables Sonarr and CouchPotato to access data from additional indexers, in a similar fashion to RSS, but with added features such as searching.
- [Plex](https://plex.tv/) Organizes your video, music, and photo collections and streams them to all of your screens.
- [Sonarr](https://sonarr.tv/) Smart PVR for newsgroup and BitTorrent users.
- [Wetty](https://github.com/krishnasrinivas/wetty) Web-based terminal client.

## Installation & Config

Run `source <(curl -s https://raw.githubusercontent.com/mcallan83/media-server/master/install.sh)` on a fresh Ubuntu 14.04 Server install.

## Web Access Ports

- Ajenti: 8000
- Couchpotato: 5050
- Deluge: 8112
- Jackett: 9117
- Plex: 32400
- Sonarr: 8989
- Wetty: 3000

## Reference Sites

- [http://www.cuttingcords.com/home/ultimate-server/getting-started](http://www.cuttingcords.com/home/ultimate-server/getting-started)
- [http://www.htpcbeginner.com/](http://www.htpcbeginner.com/)
- [https://gist.github.com/spikegrobstein/4384954](https://gist.github.com/spikegrobstein/4384954)
- [https://github.com/jknight2014/Kodi-IPVR-setup-script/](https://github.com/jknight2014/Kodi-IPVR-setup-script/)
