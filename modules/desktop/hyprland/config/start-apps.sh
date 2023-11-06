#!/usr/bin/env bash

# Set your work hours (24-hour format)
start_hour=8
end_hour=17

# Get the current hour
current_hour=$(date +%H)

# Get the current day of the week (1 = Monday, 7 = Sunday)
current_day=$(date +%u)

pcid=`hostname`
thinkpadid=laptop
oorid=nuc
desktopid=sun

FIREFOX_WORK=4
FIREFOX_HOME=4
SLACK=6
WEZTERM=1

if [ "$pcid" = "$thinkpadid" ]; then
    FIREFOX_WORK=3
    FIREFOX_HOME=2
    SLACK=4
    WEZTERM=1
elif [ "$pcid" = "$desktopid" ]; then
    echo "Desktop uses default workspaces"
elif [ "$pcid" = "$oorid" ]; then
    echo "OOR uses default workspaces"
else
    echo "Unknown PC, using default workspaces"
fi

# Check if it's a workday (Monday to Friday) and within work hours
if [ $current_day -ge 1 ] && [ $current_day -le 5 ] && [ $current_hour -ge $start_hour ] && [ $current_hour -lt $end_hour ]; then
    # Start Firefox
    hyprctl dispatch -- exec "[workspace ${FIREFOX_WORK} silent]" firefox -p work 
    hyprctl dispatch -- exec "[workspace ${SLACK} silent]" slack 
else
    echo "It's not work hours or a weekend, work apps not starting."
fi
    hyprctl dispatch -- exec "[workspace ${FIREFOX_HOME} silent]" firefox -p home
    hyprctl dispatch -- exec "[workspace ${WEZTERM} silent]" wezterm -e /home/matthew/.config/bin/ta
    hyprctl dispatch -- exec "[workspace special:spotify silent]" spotify 
 


