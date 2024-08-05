#!/bin/bash

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
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to "7.0"
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature "2700"
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic "false"
# Disable alert sounds.
gsettings set org.gnome.desktop.sound event-sounds "false"
# Remove favorite apps.
gsettings set org.gnome.shell favorite-apps "[]"
# Configure the pop shell.
gsettings set org.gnome.shell.extensions.pop-shell hint-color-rgba "rgba(13,165,219,0.75)"
gsettings set org.gnome.shell.extensions.pop-shell tile-by-default "true"
# Set workspaces.
gsettings set org.gnome.desktop.wm.preferences num-workspaces '5'

# Set enabled extensions.
gsettings set org.gnome.shell enabled-extensions \
    "[ \
        'launch-new-instance@gnome-shell-extensions.gcampax.github.com', \
        'pop-shell@system76.com', \
        'blur-my-shell@aunetx' \
    ]"
