#!/usr/bin/env bash

# Set your work hours (24-hour format)
start_hour=8
end_hour=17

# Get the current hour
current_hour=$(date +%H)

# Get the current day of the week (1 = Monday, 7 = Sunday)
current_day=$(date +%u)

# Check if it's a workday (Monday to Friday) and within work hours
if [ $current_day -ge 1 ] && [ $current_day -le 5 ] && [ $current_hour -ge $start_hour ] && [ $current_hour -lt $end_hour ]; then
    # Start Firefox
    hyprctl dispatch -- exec "[workspace 4 silent]" firefox -p work 
    hyprctl dispatch -- exec "[workspace 6 silent]" slack 
else
    echo "It's not work hours or a weekend, work apps not starting."
fi
    hyprctl dispatch -- exec "[workspace 4 silent]" firefox -p home
    hyprctl dispatch -- exec "[workspace 1 silent]" wezterm -e /home/matthew/.config/bin/ta
 


