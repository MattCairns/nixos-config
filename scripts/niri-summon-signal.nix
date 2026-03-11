{pkgs}:
pkgs.writeShellScriptBin "niri-summon-signal" ''
  focused_workspace_ref="$(
    ${pkgs.niri}/bin/niri msg -j workspaces \
      | ${pkgs.jq}/bin/jq -r '.[] | select(.is_focused) | if .name == null then (.idx | tostring) else .name end'
  )"

  signal_window_id="$(
    ${pkgs.niri}/bin/niri msg -j windows \
      | ${pkgs.jq}/bin/jq -r 'map(select(.app_id == "signal")) | first | .id // empty'
  )"

  if [[ -n "$signal_window_id" ]]; then
    ${pkgs.niri}/bin/niri msg action move-window-to-workspace --window-id "$signal_window_id" --focus true "$focused_workspace_ref"
    ${pkgs.niri}/bin/niri msg action move-window-to-floating --id "$signal_window_id"
    ${pkgs.niri}/bin/niri msg action focus-window --id "$signal_window_id"
  else
    nohup ${pkgs.signal-desktop}/bin/signal-desktop --no-sandbox >/dev/null 2>&1 &
  fi
''
