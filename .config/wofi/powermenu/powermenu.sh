##!/bin/bash

# Current Theme
dir="$HOME/.config/wofi/powermenu"
# theme='style-5'

# CMDs
uptime="`uptime -p | sed -e 's/up //g'`"
host=`hostname`

# Options
shutdown='⏻  Shutdown'
reboot='󰑓  Reboot'
lock='󰌾  Lock'
suspend='󰒲  Suspend'
logout='󰍃  Logout'
yes='  Yes'
no='  No'

# Wofi CMD
wofi_cmd() {
        wofi --dmenu \
                --prompt "Uptime: $uptime" \
#                --conf ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
        wofi --dmenu \
                --prompt 'Confirmation' \
		--columns 2 \
		--lines 2
#                --conf ${dir}/${theme}.conf
}

# Ask for confirmation
confirm_exit() {
        echo -e "$no\n$yes" | confirm_cmd
}

# Pass variables to wofi dmenu
run_wofi() {
        echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | wofi_cmd
}

# Execute Command
run_cmd() {
        selected="$(confirm_exit)"
        if [[ "$selected" == "$yes" ]]; then
                if [[ $1 == '--shutdown' ]]; then
                        systemctl poweroff
                elif [[ $1 == '--reboot' ]]; then
                        systemctl reboot
                elif [[ $1 == '--suspend' ]]; then
                        mpc -q pause
                        amixer set Master mute
                        systemctl suspend
                elif [[ $1 == '--logout' ]]; then
                        hyprctl dispatch exit 
		elif [[ $1 == '--lock' ]]; then
			swaylock -C $HOME/.config/swaylock/config
                fi
        else
                exit 0
        fi
}

# Actions
chosen="$(run_wofi)"
case ${chosen} in
    $shutdown)
                run_cmd --shutdown
        ;;
    $reboot)
                run_cmd --reboot
        ;;
    $lock)
                run_cmd --lock
        ;;
    $suspend)
                run_cmd --suspend
        ;;
    $logout)
                run_cmd --logout
        ;;
esac
