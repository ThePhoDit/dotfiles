#! /bin/bash

# Set hostname

echo "Set the hostname:\n"
read DESIRED_HOSTNAME 
sudo hostnamectl set-hostname $DESIRED_HOSTNAME

# Install SW

bash $HOME/dotfiles/setup_scripts/install_sw.sh

# Configure dotfiles
cd $HOME/dotfiles
stow .
