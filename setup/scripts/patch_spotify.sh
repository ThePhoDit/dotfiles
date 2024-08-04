#!/bin/bash

git clone https://github.com/abba23/spotify-adblock.git
cd spotify-adblock
make
mkdir -p ~/.spotify-adblock && cp target/release/libspotifyadblock.so ~/.spotify-adblock/spotify-adblock.so
mkdir -p ~/.config/spotify-adblock && cp config.toml ~/.config/spotify-adblock
flatpak override --user --filesystem="~/.spotify-adblock/spotify-adblock.so" --filesystem="~/.config/spotify-adblock/config.toml" com.spotify.Client
cp desktop_entries/spotify.desktop "$HOME/.local/share/applications/com.spotify.Client.desktop"
cd "$HOME"
rm -r spotify-adblock