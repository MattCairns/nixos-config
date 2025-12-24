{ pkgs }:

pkgs.writeShellScriptBin "monitor-hotplug" ''
  # Enhanced monitor hotplug script using mons
  # This script runs mons to detect and configure monitors

  # Prevent multiple instances from running simultaneously
  lockfile="/tmp/monitor-hotplug.lock"
  exec 200>"$lockfile"
  if ! ${pkgs.flock}/bin/flock -n 200; then
      echo "Another instance is already running, exiting."
      exit 0
  fi

  # Use mons to automatically configure monitors
  if command -v ${pkgs.mons}/bin/mons >/dev/null 2>&1; then
      # Get list of connected monitors
      connected_monitors=$(${pkgs.xorg.xrandr}/bin/xrandr --query | ${pkgs.gnugrep}/bin/grep " connected" | ${pkgs.coreutils}/bin/cut -d" " -f1)

      if [ -n "$connected_monitors" ]; then
          # Get internal monitor name (usually eDP-1, eDP-0, etc.)
          internal_monitor=$(${pkgs.xorg.xrandr}/bin/xrandr --query | ${pkgs.gnugrep}/bin/grep -E " connected" | ${pkgs.gnugrep}/bin/grep -E "eDP-[0-9]|LVDS-[0-9]|eDP1|LVDS1" | head -n1 | cut -d" " -f1)

          if [ -n "$internal_monitor" ] && [ -n "$(echo "$connected_monitors" | ${pkgs.gnugrep}/bin/grep "$internal_monitor")" ]; then
              # Set internal monitor as primary and arrange external monitors to the right
              ${pkgs.mons}/bin/mons --primary "$internal_monitor" --arrange=r
          else
              # If no internal monitor connected, use the first available monitor as primary
              primary_monitor=$(echo "$connected_monitors" | head -n1)
              ${pkgs.mons}/bin/mons --primary "$primary_monitor" --arrange=r
          fi
      else
          # No monitors connected - only internal display available, make sure it's on
          internal_display=$(${pkgs.xorg.xrandr}/bin/xrandr --query | ${pkgs.gnugrep}/bin/grep -E "eDP-[0-9]|LVDS-[0-9]|eDP1|LVDS1" | head -n1 | cut -d" " -f1)
          if [ -n "$internal_display" ]; then
              ${pkgs.xorg.xrandr}/bin/xrandr --output "$internal_display" --auto --primary
          fi
      fi

      # Wait a moment for monitors to be set up
      ${pkgs.coreutils}/bin/sleep 1

      # Refresh bspwm monitor configuration
      $HOME/.config/bspwm/bspwmrc 2>/dev/null || true

      # Restart polybar to ensure it appears on all monitors
      ${pkgs.systemd}/bin/systemctl --user restart polybar.service

      # Reset workspace assignments after monitor change
      $HOME/.config/bspwm/start-apps.sh 2>/dev/null || true
  fi

  # Release the lock
  exec 200>&-
''

