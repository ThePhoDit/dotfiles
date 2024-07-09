#!/bin/bash

# Low battery notifier
SCRIPT_NAME=$( basename $0 )
# Kill already running processes
already_running="$(ps -fC 'grep' -N | grep $SCRIPT_NAME | wc -l)"
if [[ $already_running -gt 1 ]]; then
	pkill -f --older 1 $SCRIPT_NAME
fi

# Get path
path="$( dirname "$(readlink -f "$0")" )"
last_notification_percentage="$(cat /sys/class/power_supply/BAT0/capacity)"

while [[ 0 -eq 0 ]]; do
	battery_status="$(cat /sys/class/power_supply/BAT0/status)" # Charging, Not charging, Discharging
	battery_charge="$(cat /sys/class/power_supply/BAT0/capacity)" # 0 - 100
	

	if [[ $battery_status == 'Discharging' && $battery_charge -le 25 ]]; then
		if   [[ $battery_charge -le 15 && $last_notification_percentage -gt 15 ]]; then
			notify-send --urgency=critical --expire-time 5000 "Battery critical!" "${battery_charge}%"
			last_notification_percentage=15
			sleep 480 # 8 minutes
		elif [[ $battery_charge -le 10 && $last_notification_percentage -gt 10 ]]; then
			notify-send --urgency=critical --expire-time 5000 "Battery critical!" "${battery_charge}%"
			last_notification_percentage=10
			sleep 240 # 4 minutes
		elif [[ $battery_charge -le 5 && $last_notification_percentage -gt 5 ]]; then
			notify-send --urgency=critical --expire-time 5000 "Battery critical!" "${battery_charge}%"
			last_notification_percentage=5
			sleep 180 # 2 minutes
		else
			notify-send --expire-time 5000 "Battery low!" "${battery_charge}%"
			last_notification_percentage=25	
			sleep 600 # 10 minutes
		fi
	elif [[ $battery_status == "Charging" || $battery_status == "Not charging" ]]; then
		last_notification_percentage=$battery_charge
		sleep 600 # 10 minutes
	else
		last_notification_percentage=$battery_charge
		sleep 600
	fi
done
