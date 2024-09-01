#!/bin/bash

# Control razer devices.
sudo dnf install kernel-devel
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/hardware:/razer/Fedora_$(rpm -E %fedora)/hardware:razer.repo
sudo dnf install -y openrazer-meta

flatpak install flathub xyz.z3ntu.razergenie

# Control Streamdeck.
flatpak install flathub com.feaneron.Boatswain

# OpenTabletDriver
flatpak install flathub net.opentabletdriver.OpenTabletDriver