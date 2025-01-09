#!/bin/bash

# =============
#   IMPORTANT
# =============
#
# This file is made to be run in the user's home folder without having cloned the repo.
# Relative paths cannot be used following the repo structure since the repo will be clones independently from the setup file.

# Define your custom variable names in an array
custom_names=(hostname faster_downloads cloneInHttpMode createSshKey sshPrivKeyFile enableNvidiaDrivers enableAutoLogin packageGroups)
temp_file=$(find . -type f -name "setup_output.txt")

# Initialize a counter for the array index
i=0

# Read the temporary file line by line
while IFS= read -r line; do
  # Check if we have more custom variable names
  if [ $i -lt ${#custom_names[@]} ]; then
    # Get the current custom variable name from the array
    var_name="${custom_names[$i]}"

    # Assign the current line to the custom variable
    eval "$var_name=\"$line\""

    # Increment the array index counter
    i=$((i + 1))
  else
    # No more custom variable names - handle accordingly (e.g., break the loop)
    break
  fi
done < "$temp_file"

rm setup_output.txt

# All variables set.

set -e

# Configure DNF settings.
if [[ "$faster_downloads" == "true" ]] ; then
	echo -e "\nConfiguring DNF..."
	echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
	echo "fastestmirror=true" | sudo tee -a /etc/dnf/dnf.conf
fi

# Ask the user for a hostname and set it.
echo -e "\nSetting hostname..."
hostnamectl set-hostname "$hostname"

cd "$HOME"

if [[ "$cloneInHttpMode" == "true" ]] ; then
	git clone --branch fedora https://github.com/ThePhoDit/dotfiles.git "$HOME/dotfiles"
else
	if [[ "$createSshKey" == "true" ]] ; then
		ssh-keygen -t ed25519 -f "$sshPrivKeyFile"
	fi

	# Display public key so it can be imported into GitHub.
    echo -e "\n You are now going to be shown your public key. Copy it and add it to your GitHub account."
    if [[ "$sshPrivKeyFile" != *.pub ]] ; then
        sshPubKeyFile="${sshPrivKeyFile}.pub"
    else
    	sshPubKeyFile="${sshPrivKeyFile}"
    fi

    echo -e "\n When you are done, press any key.\n"
    cat "$sshPubKeyFile"
    read dummy
    git clone --branch fedora git@github.com:ThePhoDit/dotfiles.git
    break
fi

cd "$HOME/dotfiles/setup"

# Remove unwanted GNOME software.
echo -e "\nRemoving bloatware..."
sudo dnf remove -y $(grep "^[^#]" packages/uninstall.txt)

# Run a system update.
echo -e "\nUpgrading system..."
sudo dnf -y --refresh upgrade

# Enable third party directories.
echo -e "\nEnabling additional repositories..."
# RPM Fusion Free
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
# RPM Fusion Non Free
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# Terra
sudo dnf install --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' --setopt='terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' terra-release
# Flatpak Repos
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

# Librewolf Repo
sudo curl -fsSL https://rpm.librewolf.net/librewolf-repo.repo | pkexec tee /etc/yum.repos.d/librewolf.repo

# COPR Packages
sudo dnf copr enable principis/NoiseTorch
sudo dnf copr enable iucar/rstudio

for group in $packageGroups ; do
	case "$group" in
		"base")
			# Install packages from the repos.
			echo -e "\nInstalling additional software..."
			sudo dnf install -y --skip-broken $(grep "^[^#]" packages/install.txt)

			# Install Flatpak packages.
			bash scripts/flatpak_install.sh

			# Change back to the home directory.
			cd "$HOME"

			# Install Oh My Posh
			curl -s https://ohmyposh.dev/install.sh | bash -s

			cd "$HOME/dotfiles/setup"

			# Patch Spotify.
			bash scripts/patch_spotify.sh

			# Create conda environment for Jupyter.
			bash scripts/setup_jupyter.sh

			# Install NVM
			wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

			# Enable Synthing
			sudo systemctl enable "syncthing@$USER.service"
			sudo systemctl start "syncthing@$USER.service"

			# Enable ZeroTier
			sudo systemctl enable zerotier
			sudo systemctl start zerotier

			# Enable Tor
			sudo systemctl enable tor
			sudo systemctl start tor

			# Set default browser.
			xdg-settings set default-web-browser librewolf.desktop
			;;
		"media")
			# TODO
			echo -e "\nInstalling media packages..."
			bash scripts/media_install.sh
			;;
		"desktop")
			echo -e "\n Installing desktop utils..."
			bash scripts/desktop_utils_install.sh
			;;
		"vencord")
			echo -e "\n Installing Vencord..."
			bash scripts/vencord_install.sh
			;;
	esac
done



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

cd "$HOME/dotfiles/setup"

# Set GNOME settings.
echo -e "\nMaking additional changes..."
bash scripts/set_gnome_settings.sh

# Set keybinds.
echo -e "\nSetting keybinds..."
bash scripts/set_keybinds.sh

# Change user shell.
chsh -s $(which zsh)

# Linking dotfiles.
echo -e "\nSetting dotfiles..."
cd "$HOME/dotfiles"
stow .

# Enable autologin if an encrypted disk is found.
if [[ "$enableAutoLogin" == "true" ]] ; then
	# Enables autologin in the config file, under the [daemon] line.
	sudo sed -i "/\[daemon\]/a AutomaticLoginEnable=True\nAutomaticLogin=$USER" /etc/gdm/custom.conf
	echo "Autologin has been enabled."
	break
else
	echo "Autologin won't be enabled."
	break
fi

if [[ "$enableNvidiaDrivers" == "true" ]] ; then
	sudo dnf install akmod-nvidia
	while true ; do
		echo -n "Install CUDA support? (y/N): "
		read install_cuda

		if [[ "$install_cuda" =~ [Yy] ]] ; then
			sudo dnf install xorg-x11-drv-nvidia-cuda
			echo "CUDA support installed."
			break
		elif [[ "$install_cuda" =~ [Nn] || -z "$install_cuda" ]] ; then
			echo "CUDA not installed."
			break
		fi
	done
	echo "Drivers installed."
fi

echo -e "\n\nInstallation complete!\nYou should reboot this PC now."
