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

# Disable power button default behaviour
sudo cp $HOME/dotfiles/other_files/logind.conf /etc/systemd/logind.conf

# Change shell

echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish

# Reboot
sudo reboot
