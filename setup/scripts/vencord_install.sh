#!/bin/bash

flatpak install -y flathub-beta com.discordapp.DiscordCanary
sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"