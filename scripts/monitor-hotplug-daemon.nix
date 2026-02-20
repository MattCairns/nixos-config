{ pkgs, monitorHotplug }:

pkgs.writeShellScriptBin "monitor-hotplug-daemon" ''
  # Monitor for changes in connected displays
  # This approach polls xrandr, but it's the most reliable for automatic detection
  PREV_OUTPUT=""

  # Wait a bit to ensure X session is fully loaded
  ${pkgs.coreutils}/bin/sleep 3

  # Prevent multiple instances from running simultaneously
  lockfile="/tmp/monitor-hotplug-daemon.lock"
  exec 200>"$lockfile"
  if ! ${pkgs.flock}/bin/flock -n 200; then
      echo "Another instance is already running, exiting."
      exit 0
  fi

  while true; do
      # Only proceed if we can access the X server
      if ${pkgs.xset}/bin/xset q &>/dev/null; then
          CURRENT_OUTPUT=$(${pkgs.xrandr}/bin/xrandr --query 2>/dev/null | ${pkgs.gnugrep}/bin/grep " connected" | ${pkgs.coreutils}/bin/sort)
      else
          # If X server is not accessible, wait a bit longer and try again
          ${pkgs.coreutils}/bin/sleep 5
          continue
      fi

      if [ "$CURRENT_OUTPUT" != "$PREV_OUTPUT" ]; then
          echo "Monitor configuration changed, running mons..."

          # Run the monitor hotplug script
          DISPLAY=:0 ${monitorHotplug}/bin/monitor-hotplug

          PREV_OUTPUT=$CURRENT_OUTPUT
      fi

      ${pkgs.coreutils}/bin/sleep 2  # Check every 2 seconds
  done

  # Release the lock
  exec 200>&-
''
