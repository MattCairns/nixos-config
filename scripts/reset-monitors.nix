{pkgs}:
pkgs.writeShellScriptBin "reset-monitors" ''
  # Reset all monitors by cycling DPMS and reloading Hyprland configuration
  # Useful for fixing monitors that don't wake properly after sleep

  # Check if Hyprland is running (unless --force flag is used)
  if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ] && [ "$1" != "--force" ]; then
      echo "Error: Hyprland is not running. This script must be run from within a Hyprland session."
      echo "Use 'reset-monitors --force' to test anyway (may fail if Hyprland isn't running)"
      exit 1
  fi

  # Prevent multiple instances from running simultaneously
  lockfile="/tmp/reset-monitors.lock"
  exec 200>"$lockfile"
  if ! ${pkgs.flock}/bin/flock -n 200; then
      ${pkgs.libnotify}/bin/notify-send "Monitor Reset" "Already running, please wait..." 2>/dev/null || true
      exit 0
  fi

  # Notify user that reset is starting (suppress errors if notification daemon isn't running)
  ${pkgs.libnotify}/bin/notify-send "Monitor Reset" "Resetting displays..." 2>/dev/null || true

  # Force all displays off via DPMS
  ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
  ${pkgs.coreutils}/bin/sleep 1

  # Force all displays back on
  ${pkgs.hyprland}/bin/hyprctl dispatch dpms on
  ${pkgs.coreutils}/bin/sleep 0.5

  # Reload Hyprland configuration to reapply monitor rules
  ${pkgs.hyprland}/bin/hyprctl reload

  # Restart waybar to fix any status bar rendering issues
  ${pkgs.procps}/bin/pkill waybar
  ${pkgs.coreutils}/bin/sleep 0.3
  ${pkgs.waybar}/bin/waybar &

  # Notify user of success (suppress errors if notification daemon isn't running)
  ${pkgs.libnotify}/bin/notify-send "Monitor Reset" "Display reset complete" 2>/dev/null || true

  # Release the lock
  exec 200>&-
''
