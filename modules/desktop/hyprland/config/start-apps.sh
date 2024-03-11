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
frameworkid=framework
oorid=nuc
desktopid=sun

FIREFOX_WORK=2
FIREFOX_HOME=3
SLACK=4
KITTY=1

if [ "$pcid" = "$thinkpadid" ] || [ "$pcid" = "$frameworkid" ]; then
    FIREFOX_WORK=2
    FIREFOX_HOME=3
    SLACK=4
    KITTY=1
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
    hyprctl dispatch -- exec "[workspace ${KITTY} silent]" kitty -e /home/matthew/.config/bin/ta
    hyprctl dispatch -- exec "[workspace special:spotify silent]" spotify 
 


