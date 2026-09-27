{
  pkgs,
  externalMonitorOne,
  externalMonitorTwo,
}:
pkgs.writeShellScriptBin "hypr-workspace-router" ''
  set -uo pipefail

  export PATH="${pkgs.hyprland}/bin:${pkgs.jq}/bin:$PATH"

  lock_file="''${XDG_RUNTIME_DIR:-/tmp}/hypr-workspace-router.lock"
  exec 9>"$lock_file"
  if ! ${pkgs.util-linux}/bin/flock -n 9; then
    exit 0
  fi

  # Monitor events arrive in bursts; let Hyprland settle before reading state.
  sleep 2

  # Docked means both external monitors are connected. Counting externals
  # rather than all monitors keeps the layout docked when the lid is closed
  # and eDP-1 is disabled.
  externals="$(hyprctl monitors -j 2>/dev/null | jq '[.[] | select(.name != "eDP-1")] | length' 2>/dev/null || printf '0')"
  if [ "$externals" -ge 2 ]; then
    PROFILE="docked"
  else
    PROFILE="undocked"
  fi

  is_locked() {
    ${pkgs.procps}/bin/pidof hyprlock >/dev/null 2>&1
  }

  migrate_windows() {
    # Usage: migrate_windows <class> <target_workspace>
    if is_locked; then
      return 0
    fi

    local class="$1"
    local target="$2"

    hyprctl clients -j 2>/dev/null \
      | jq -c --arg cls "$class" '.[] | select(.class == $cls)' \
      | while IFS= read -r client; do
          local addr ws
          addr=$(echo "$client" | jq -r '.address')
          ws=$(echo "$client" | jq -r '.workspace.id')
          if [ "$ws" != "$target" ]; then
            hyprctl dispatch movetoworkspacesilent "$target,address:$addr" 2>/dev/null || true
          fi
        done
  }

  apply_undocked() {
    # Rebind workspaces 4-10 to the laptop screen so they remain reachable.
    for ws in 4 5 6 7 8 9 10; do
      hyprctl keyword workspace "$ws, monitor:eDP-1" 2>/dev/null || true
    done

    # Migrate already-open windows to the undocked workspace layout. New
    # windows are left wherever they are opened.
    migrate_windows "kitty" "1"
    migrate_windows "Obsidian" "2"
    migrate_windows "obsidian" "2"
    migrate_windows "firefox-home" "3"
    migrate_windows "firefox-work" "4"
    migrate_windows "Slack" "5"
    migrate_windows "slack" "5"
  }

  apply_docked() {
    # Restore workspace-to-monitor bindings for the 3-monitor layout.
    hyprctl keyword workspace "1, monitor:eDP-1, default:true" 2>/dev/null || true
    hyprctl keyword workspace "2, monitor:eDP-1" 2>/dev/null || true
    hyprctl keyword workspace "3, monitor:eDP-1" 2>/dev/null || true
    hyprctl keyword workspace "4, monitor:${externalMonitorOne}, default:true" 2>/dev/null || true
    hyprctl keyword workspace "5, monitor:${externalMonitorOne}" 2>/dev/null || true
    hyprctl keyword workspace "6, monitor:${externalMonitorOne}" 2>/dev/null || true
    hyprctl keyword workspace "7, monitor:${externalMonitorTwo}, default:true" 2>/dev/null || true
    hyprctl keyword workspace "8, monitor:${externalMonitorTwo}" 2>/dev/null || true
    hyprctl keyword workspace "9, monitor:${externalMonitorTwo}" 2>/dev/null || true
    hyprctl keyword workspace "10, monitor:${externalMonitorTwo}" 2>/dev/null || true

    # Existing workspaces do not always move when workspace rules are updated.
    for ws in 4 5 6; do
      hyprctl dispatch moveworkspacetomonitor "$ws" "${externalMonitorOne}" 2>/dev/null || true
    done
    for ws in 7 8 9 10; do
      hyprctl dispatch moveworkspacetomonitor "$ws" "${externalMonitorTwo}" 2>/dev/null || true
    done

    # Migrate already-open windows back to their docked workspaces.
    migrate_windows "kitty" "4"
    migrate_windows "Obsidian" "5"
    migrate_windows "obsidian" "5"
    migrate_windows "firefox-home" "7"
    migrate_windows "firefox-work" "7"
    migrate_windows "Slack" "9"
    migrate_windows "slack" "9"
  }

  case "$PROFILE" in
    undocked) apply_undocked ;;
    docked) apply_docked ;;
  esac
''
