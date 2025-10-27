#!/usr/bin/env bash

start_hour=8
end_hour=17

current_hour=$(date +%H)
current_day=$(date +%u)

launch_to_workspace() {
  local workspace="$1"
  shift
  if [ -z "$workspace" ]; then
    "$@" &
    return
  fi

  "$@" &
  local pid=$!

  if command -v xdotool >/dev/null 2>&1; then
    # Wait for the window to appear and move it to the requested workspace
    for _ in $(seq 1 50); do
      local win
      win=$(xdotool search --sync --onlyvisible --pid "$pid" 2>/dev/null | head -n1)
      if [ -n "$win" ]; then
        bspc node "$win" -d "^${workspace}" 2>/dev/null
        break
      fi
      sleep 0.2
    done
  fi
}



if [ $current_day -ge 1 ] && [ $current_day -le 5 ] && [ $current_hour -ge $start_hour ] && [ $current_hour -lt $end_hour ]; then
  launch_to_workspace "$FIREFOX_WORK" firefox -p work
  launch_to_workspace "$SLACK" slack --disable-gpu
  launch_to_workspace "$OBSIDIAN" obsidian
else
  echo "Outside work hours; skipping work apps."
fi

launch_to_workspace "$FIREFOX_HOME" firefox -p home
launch_to_workspace "$KITTY" kitty -e /home/matthew/.config/bin/ta
launch_to_workspace "$SPOTIFY" spotify
