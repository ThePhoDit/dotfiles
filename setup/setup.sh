#!/bin/bash

# =============
#   IMPORTANT
# =============
#
# This file is made to be run in the user's home folder without having cloned the repo.
# Relative paths cannot be used following the repo structure since the repo will be clones independently from the setup file.

set -e

# Configure DNF settings.
echo -e "\nConfiguring DNF..."
echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
echo "fastestmirror=true" | sudo tee -a /etc/dnf/dnf.conf

# Ask the user for a hostname and set it.
echo -e "\nSet a hostname"
read host
hostnamectl set-hostname "$host"

cd "$HOME"

# Choose how to clone the GitHub repo. If the user is the author of this script, with access to the repo with write permissions, an SSH key will be generated.
echo -e "\n\nDo you want to clone the repo in HTTP mode? If not, SSH will be used, generating an SSH key. (Y/n)"
read clone_response
if [[ "$clone_response" =~ [Yy] || "$clone_response" == "" ]]; then
    git clone --branch fedora https://github.com/ThePhoDit/dotfiles.git
elif [[ "$clone_response" =~ [Nn] ]]; then
    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
	echo -e "\nDo you want to replace an already existing key? (y/N)"
	read replace_key

	if [[ "$replace_key" =~ [Yy] ]]; then
    		ssh-keygen -t ed25519
	fi
    fi
    echo -e "\n You are now going to be shown your public key (asuming default directory). Copy it and add it to your GitHub account."
    echo -e "\n When you are done, press any key.\n"
    cat "$HOME/.ssh/id_ed25519.pub"
    read dummy
    git clone --branch fedora git@github.com:ThePhoDit/dotfiles.git
fi

cd "$HOME/dotfiles/setup"
chmod u+x scripts/*.sh

# Remove unwanted GNOME software.
echo -e "\nRemoving bloatware..."
sudo dnf remove -y $(grep "^[^#]" bloatware)

# Run a system update.
echo -e "\nUpgrading system..."
sudo dnf -y --refresh upgrade

# Enable third party directories.
echo -e "\nEnabling additional repositories..."
# RPM Fusion Free
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
# RPM Fusion Non Free
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# Librewolf
curl -fsSL https://rpm.librewolf.net/librewolf-repo.repo | sudo pkexec tee /etc/yum.repos.d/librewolf.repo
# Terra
sudo dnf install --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' --setopt='terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' terra-release

# Install packages from the repos.
echo -e "\nInstalling additional software..."
sudo dnf install -y --skip-broken $(grep "^[^#]" packages)

# Change back to the home directory.
cd "$HOME"

# Install IntelliJ IDEA.
wget https://download.jetbrains.com/idea/ideaIU-2024.1.4.tar.gz
sudo tar -xzf ideaIU-*.tar.gz -C /opt/
sudo chmod 755 /opt/idea-IU*/
rm ideaIU-*.tar.gz

# Install Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash -s

cd "$HOME/dotfiles/setup"

# Install Spotify.
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub com.spotify.Client
bash scripts/patch_spotify.sh

# Create conda environment for Jupyter.
bash scripts/setup_jupyter.sh

cd "$HOME"

# Install user fonts.
echo -e "\nInstalling fonts..."
fonts_path="$HOME/.local/share/fonts"
# Download fonts.
wget -P "$fonts_path" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraMono.zip
wget -P "$fonts_path" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
# Unzip fonts.
unzip "$fonts_path/FiraMono.zip" -d "$fonts_path"
unzip "$fonts_path/FiraCode.zip" -d "$fonts_path"
rm "$fonts_path"/Fira*.zip
# Reload fonts cache.
fc-cache -fv

# Other settings.
echo -e "\nMaking additional changes..."
# Set dark mode.
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# Set timezone.
timedatectl set-timezone Europe/Madrid
# Set 24 hour clock format.
gsettings set org.gnome.desktop.interface clock-format "'24h'"
# Set keyboard layout.
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+intl')]"
# Enable minimize and maximize buttons.
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
# Disable hot corner.
gsettings set org.gnome.desktop.interface enable-hot-corners "false"
# Set power button behavior.
gsettings set org.gnome.settings-daemon.plugins.power power-button-action "interactive"
# Show battery percentage.
gsettings set org.gnome.desktop.interface show-battery-percentage "true"
# Set night light.
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled "true"
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from "22.5"
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from "7.0"
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature "2700"
# Disable alert sounds.
gsettings set org.gnome.desktop.sound event-sounds "false"


# Set keybinds.
echo -e "\nSetting keybinds..."
for i in {1..9}
do
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done

# Placement keybinds.
gsettings set org.gnome.desktop.wm.keybindings move-to-side-e "['<Super><Shift>L']"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-w "['<Super><Shift>H']"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-n "['<Super><Shift>K']"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-s "['<Super><Shift>J']"

gsettings set org.gnome.desktop.wm.keybindings move-to-corner-ne "['<Super><Control>L']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-nw "['<Super><Control>H']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-se "['<Super><Control>K']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-sw "['<Super><Control>J']"

gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Super>C']"

# Launch kitty terminal.
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Launch Kitty'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Super>Return'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'kitty'"

# Load all custom keybinds.
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

# Change user shell.
chsh -s $(which zsh)

# Linking dotfiles.
echo -e "\nSetting dotfiles..."
cd "$HOME/dotfiles"
stow .

echo -e "\n\nInstallation complete!"
