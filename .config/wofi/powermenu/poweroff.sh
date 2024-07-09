#!/bin/bash

yes="   Yes"
no="   No"

prompt="`echo Power off? | sed -e 's/up //g'`"

wofi_cmd() {
	wofi --dmenu --prompt "$prompt" --columns 2 --lines 2
}


confirm_poweroff() {
	echo -e "$no\n$yes" | wofi_cmd
}


chosen="$(confirm_poweroff)"

if [[ "$chosen" == "$yes" ]]; then
       systemctl poweroff
else
 	exit 0
fi	
