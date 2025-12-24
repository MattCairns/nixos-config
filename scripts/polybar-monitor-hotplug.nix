{ pkgs }:

pkgs.writeShellScriptBin "polybar-monitor-hotplug" ''
  #!${pkgs.bash}/bin/bash
  export DISPLAY=:0
  export XAUTHORITY=$HOME/.Xauthority

  # Function to check monitor configuration and restart polybar if changed
  check_and_restart_polybar() {
      local current_monitors
      current_monitors=$(${pkgs.xrandr}/bin/xrandr --query | ${pkgs.gnugrep}/bin/grep -c " connected")

      # Compare with expected polybar instances count (should match connected monitor count)
      local running_polybar_count
      running_polybar_count=$(${pkgs.busybox}/bin/pgrep -c polybar 2>/dev/null || echo 0)

      if [ "$running_polybar_count" -ne "$current_monitors" ]; then
          echo "Monitor configuration changed, restarting polybar..."
          ${pkgs.procps}/bin/pkill polybar
          ${pkgs.coreutils}/bin/sleep 1
          # Wait for polybar to fully stop
          while ${pkgs.busybox}/bin/pgrep -x polybar >/dev/null; do ${pkgs.coreutils}/bin/sleep 0.5; done
          # Start polybar again (it will detect all current monitors)
          systemctl --user restart polybar 2>/dev/null || true
      fi
  }

  # Initial check
  check_and_restart_polybar

  # Monitor for display configuration changes
  while true; do
      ${pkgs.coreutils}/bin/sleep 3
      check_and_restart_polybar
  done
''
