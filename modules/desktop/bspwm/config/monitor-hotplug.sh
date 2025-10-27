#!/usr/bin/env bash

# Monitor hotplug script using mons
# This script runs mons to detect and configure monitors

# Use mons to automatically configure monitors
if command -v mons >/dev/null 2>&1; then
    # Get internal monitor name (usually eDP-1, eDP-0, etc.)
    internal_monitor=$(xrandr --query | grep -E "eDP-[0-9]|LVDS-[0-9]|eDP1|LVDS1" | head -n1 | cut -d" " -f1)
    
    if [ -n "$internal_monitor" ]; then
        # Set internal monitor as primary and arrange external monitors to the right
        mons --primary "$internal_monitor" --arrange=r
    else
        # If no internal monitor detected, just arrange all monitors
        mons --arrange=r
    fi
    
    # Wait a moment for monitors to be set up
    sleep 1
    
    # Refresh bspwm monitor configuration
    ~/.config/bspwm/bspwmrc
    
    # Restart polybar to ensure it appears on all monitors
    pkill polybar
    sleep 1
    # Wait for polybar to fully stop
    while pgrep -x polybar >/dev/null; do sleep 0.5; done
    # Start polybar again (it will detect all current monitors)
    systemctl --user restart polybar.service
fi