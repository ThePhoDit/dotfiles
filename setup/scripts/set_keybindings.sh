for i in {1..9} ; do
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

gsettings set org.gnome.desktop.wm.keybindings minimize "[]"

gsettings set org.gnome.settings-daemon.plugins.media-keys www "[]"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "[]"

# Launch kitty terminal.
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Launch Kitty'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Super>T'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'kitty'"

# Launch web browser.
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "'Launch Librewolf'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "'<Super>B'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "'librewolf'"

# Launch file explorer.
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name "'Launch Nautilus'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "'<Super>F'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command "'nautilus'"

# Launch Zed text editor.
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name "'Launch Zed'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding "'<Super>E'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command "'zed'"


# Load all custom keybinds.
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "[ \
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/',
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', \
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', \
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/' \
    ]"
