{
  pkgs,
  externalMonitorOne,
  externalMonitorTwo,
  systemd ? pkgs.systemd,
}:
pkgs.writeShellScriptBin "hypr-workspace-router" ''
  set -uo pipefail

  export PATH="${pkgs.hyprland}/bin:${pkgs.jq}/bin:$PATH"

  PROFILE="''${1:-undocked}"

  # Wait for Hyprland to register the monitor change before issuing commands.
  sleep 1

  migrate_windows() {
    # Usage: migrate_windows <class> <target_workspace>
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

    # Override window rules so newly opened apps land on undocked workspaces.
    hyprctl keyword windowrule "workspace 1 silent, match:class ^(kitty)$" 2>/dev/null || true
    hyprctl keyword windowrule "workspace 2 silent, match:class ^(obsidian|Obsidian)$" 2>/dev/null || true
    hyprctl keyword windowrule "workspace 3 silent, match:class ^(firefox-home)$" 2>/dev/null || true
    hyprctl keyword windowrule "workspace 4 silent, match:class ^(firefox-work)$" 2>/dev/null || true
    hyprctl keyword windowrule "workspace 5 silent, match:class ^(Slack|slack)$" 2>/dev/null || true

    # Migrate any already-open windows to the undocked workspace layout.
    migrate_windows "kitty" "1"
    migrate_windows "Obsidian" "2"
    migrate_windows "obsidian" "2"
    migrate_windows "firefox-home" "3"
    migrate_windows "firefox-work" "4"
    migrate_windows "Slack" "5"
    migrate_windows "slack" "5"
    # Restart noctalia so it re-initialises wallpaper and the bar on the
    # current monitor set. Brief pause lets Hyprland settle first.
    sleep 1
    ${systemd}/bin/systemctl --user restart noctalia-shell.service
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

    # Override window rules so newly opened apps land on docked workspaces.
    hyprctl keyword windowrule "workspace 4 silent, match:class ^(kitty)$" 2>/dev/null || true
    hyprctl keyword windowrule "workspace 5 silent, match:class ^(obsidian|Obsidian)$" 2>/dev/null || true
    hyprctl keyword windowrule "workspace 7 silent, match:class ^(firefox-home)$" 2>/dev/null || true
    hyprctl keyword windowrule "workspace 7 silent, match:class ^(firefox-work)$" 2>/dev/null || true
    hyprctl keyword windowrule "workspace 9 silent, match:class ^(Slack|slack)$" 2>/dev/null || true

    # Migrate any already-open windows back to their docked workspaces.
    migrate_windows "kitty" "4"
    migrate_windows "Obsidian" "5"
    migrate_windows "obsidian" "5"
    migrate_windows "firefox-home" "7"
    migrate_windows "firefox-work" "7"
    migrate_windows "Slack" "9"
    migrate_windows "slack" "9"
    # Restart noctalia so it re-initialises wallpaper and the bar on the
    # current monitor set. Brief pause lets Hyprland settle first.
    sleep 1
    ${systemd}/bin/systemctl --user restart noctalia-shell.service
  }

  case "$PROFILE" in
    undocked | fallback) apply_undocked ;;
    docked) apply_docked ;;
    *)
      printf 'hypr-workspace-router: unknown profile: %s\n' "$PROFILE" >&2
      exit 1
      ;;
  esac
''
