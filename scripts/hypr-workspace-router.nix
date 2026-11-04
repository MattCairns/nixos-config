{
  pkgs,
  lib,
  externalMonitorOne,
  externalMonitorTwo,
  # From modules/desktop/hyprland: app -> {classes, docked, undocked}.
  layout,
  # hl.workspace_rule tables (Hyprland Lua config).
  workspaceRules,
  countExternals,
}: let
  toLua = lib.generators.toLua {multiline = false;};
  migrateAll = profile:
    lib.concatStrings (lib.concatLists (lib.mapAttrsToList (_: app:
      map (class: ''
        migrate_windows "${class}" "${toString app.${profile}}"
      '')
      app.classes)
    layout));
in
  pkgs.writeShellScriptBin "hypr-workspace-router" ''
    set -uo pipefail

    export PATH="${pkgs.hyprland}/bin:${pkgs.jq}/bin:$PATH"

    lock_file="''${XDG_RUNTIME_DIR:-/tmp}/hypr-workspace-router.lock"
    exec 9>"$lock_file"
    # Wait rather than skip, so the last event of a burst sees the final state.
    ${pkgs.util-linux}/bin/flock 9

    # Monitor events arrive in bursts; let Hyprland settle before reading state.
    sleep 2

    # Docked means both external monitors are connected.
    externals="$(${countExternals} 2>/dev/null || printf '0')"
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
              hyprctl dispatch "hl.dsp.window.move({ workspace = \"$target\", follow = false, window = \"address:$addr\" })" >/dev/null 2>&1 || true
            fi
          done
    }

    apply_undocked() {
      # Rebind workspaces 4-10 to the laptop screen so they remain reachable.
      for ws in 4 5 6 7 8 9 10; do
        hyprctl eval "hl.workspace_rule({ workspace = \"$ws\", monitor = \"eDP-1\" })" >/dev/null 2>&1 || true
      done

      # Migrate already-open windows to the undocked workspace layout. New
      # windows are left wherever they are opened.
      ${migrateAll "undocked"}
    }

    apply_docked() {
      # Restore workspace-to-monitor bindings for the 3-monitor layout.
      ${lib.concatMapStrings (rule: ''
        hyprctl eval ${lib.escapeShellArg "hl.workspace_rule(${toLua rule})"} >/dev/null 2>&1 || true
      '')
      workspaceRules}

      # Existing workspaces do not always move when workspace rules are updated.
      for ws in 4 5 6; do
        hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"${externalMonitorOne}\" })" >/dev/null 2>&1 || true
      done
      for ws in 7 8 9 10; do
        hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"${externalMonitorTwo}\" })" >/dev/null 2>&1 || true
      done

      # Migrate already-open windows back to their docked workspaces.
      ${migrateAll "docked"}
    }

    case "$PROFILE" in
      undocked) apply_undocked ;;
      docked) apply_docked ;;
    esac
  ''
