#!/bin/bash

# Control razer devices.
sudo dnf install kernel-devel
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/hardware:/razer/Fedora_$(rpm -E %fedora)/hardware:razer.repo
sudo dnf install -y openrazer-meta

flatpak install -y flathub xyz.z3ntu.razergenie

# Control Streamdeck.
flatpak install -y flathub com.core447.StreamController

# OpenTabletDriver
flatpak install -y flathub net.opentabletdriver.OpenTabletDriver

# Install MultiMC
PREV_DIR=$(pwd)

cd "$HOME"
wget https://files.multimc.org/downloads/mmc-develop-lin64.tar.gz
tar -xzf mmc-develop-lin64.tar.gz

mkdir "$HOME/Apps" > /dev/null 2>&1

mv MultiMC "$HOME/Apps/MultiMC"

rm mmc-develop-lin64.tar.gz

cd "$HOME/Apps/MultiMC"

wget https://multimc.org/images/infinity32.png

chmod u+x bin/MultiMC

cd "$HOME"

cp dotfiles/setup/desktop_entries/multimc.desktop "$HOME/.local/share/applications/multimc.desktop"
echo -e "\nExec=$HOME/Apps/MultiMC/bin/MultiMC" >> "$HOME/.local/share/applications/multimc.desktop"
echo "Icon=$HOME/Apps/MultiMC/infinity32.png" >> "$HOME/.local/share/applications/multimc.desktop"

cd PREV_DIR