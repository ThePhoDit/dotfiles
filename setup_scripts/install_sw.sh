#! /bin/bash

# Set hostname

echo "Set the hostname:\n"
read DESIRED_HOSTNAME 
sudo hostnamectl set-hostname $DESIRED_HOSTNAME

# Add flatpak repos and install packages

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub $( cat $HOME/dotfiles/setup_scripts/apps/flatpak.txt )

# Install ZeroTier

curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/main/doc/contact%40zerotier.com.gpg' | gpg --import && \
if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi

# Install dnf packages

sudo dnf install $( cat $HOME/dotfiles/setup_scripts/apps/dnf.txt )

sudo systemctl enable --now syncthing@mario
