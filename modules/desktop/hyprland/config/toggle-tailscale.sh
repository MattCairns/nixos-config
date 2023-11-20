#!/usr/bin/env bash

current_account=$(sudo tailscale status |  awk '{print $3;exit}')
echo $current_account

if [[ $current_account == "mattrcairns@" ]]; then
   echo "Switching to work account..."
   sudo tailscale switch work
else 
   echo "Switching to personal account..."
   sudo tailscale switch home
fi

