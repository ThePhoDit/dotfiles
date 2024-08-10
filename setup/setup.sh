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
echo -en "\nDo you want to clone the repo in HTTP mode? If not, SSH will be used, generating an SSH key. (Y/n): "

while true ; do
    read clone_response

    # Cloning in HTTP mode.
    if [[ "$clone_response" =~ [Yy] || -z "$clone_response" ]] ; then
        git clone --branch fedora https://github.com/ThePhoDit/dotfiles.git "$HOME/dotfiles"
        break
    # Cloning in SSH mode.
    elif [[ "$clone_response" =~ [Nn] ]] ; then
        if [[ -f "$HOME/.ssh/id_ed25519.pub" ]] ; then
           	echo -n "Do you want to replace an already existing key? (y/N): "

            while true ; do
           	    read replace_key

               	if [[ "$replace_key" =~ [Yy] ]] ; then
              		ssh-keygen -t ed25519
                    break
                elif [[ "$replace_key" =~ [Nn] || -z "$replace_key" ]] ; then
                    break
               	fi
            done
        fi

        # Display public key so it can be imported into GitHub.
        echo -e "\n You are now going to be shown your public key. Copy it and add it to your GitHub account."

        # Ask for key directory. Empty defaults to ~/.ssh/id_ed25519.pub
        while true ; do
            echo -n "Public key file: "
            read pub_key_file

            if [[ -z "$pub_key_file" ]] ; then
                pub_key_file="$HOME/.ssh/id_ed25519.pub"
            fi

            if [[ "$pub_key_file" != *.pub ]] ; then
                pub_key_file="${pub_key_file}.pub"
            fi

            if [[ -f "$pub_key_file" ]] ; then
                break
            fi

            echo "File $pub_key_file does not exist."
        done

        echo -e "\n When you are done, press any key.\n"
        cat "$pub_key_file"
        read dummy
        git clone --branch fedora git@github.com:ThePhoDit/dotfiles.git
        break
    fi
done

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

# COPR Packages
sudo dnf copr enable useidel/signal-desktop 
sudo dnf copr enable principis/NoiseTorch

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

# Enable Synthing
sudo systemctl enable "syncthing@$USER.service"
sudo systemctl start "syncthing@$USER.service"

# Enable ZeroTier
sudo systemctl enable zerotier
sudo systemctl start zerotier

# Set default browser.
xdg-settings set default-web-browser librewolf.desktop

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
echo -e "\nChecking partitions..."
if lsblk | grep -q "crypt" ; then
	echo "An encripted partition has been detected."
	while true ; do
		echo -n "Would you like to enable autologin for the current user? (y/N): "
		read enable_auto_login
		
		if [[ "$enable_auto_login" =~ [Yy] ]] ; then
			# Enables autologin in the config file, under the [daemon] line.
			sudo sed -i "/\[daemon\]/a AutomaticLoginEnable=True\nAutomaticLogin=$USER" /etc/gdm/custom.conf
			echo "Autologin has been enabled."
			break
		elif [[ "$enable_auto_login" =~ [Nn] || -z "$enable_auto_login" ]] ; then
			echo "Autologin won't be enabled."
			break
		fi
	done
fi

# Install NVidia drivers if card is found.
echo -e "\nChecking for graphic cards..."
if sudo lspci -v | grep -iq "nvidia" ; then
	echo "A NVidia graphics card has been detected."
	while true ; do
		echo -n "Would you like to install propietary drivers for it? If your card has an old chipset please say 'N' as they will not work. (y/N): "
		read install_nvidia_drivers
		
		if [[ "$install_nvidia_drivers" =~ [Yy] ]] ; then
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
			echo "Drivers have been installed."
			break
		elif [[ "$install_nvidia_drivers" =~ [Nn] || -z "$install_nvidia_drivers" ]] ; then
			echo "Drivers won't be installed."
			break
		fi
	done
fi

echo -e "\n\nInstallation complete!\nYou should reboot this PC now."
