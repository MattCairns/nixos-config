{pkgs}:
pkgs.writeShellScriptBin "niri-summon-spotify" ''
  focused_workspace_ref="$(
    ${pkgs.niri}/bin/niri msg -j workspaces \
      | ${pkgs.jq}/bin/jq -r '.[] | select(.is_focused) | if .name == null then (.idx | tostring) else .name end'
  )"

  spotify_window_id="$(
    ${pkgs.niri}/bin/niri msg -j windows \
      | ${pkgs.jq}/bin/jq -r 'map(select(.app_id == "spotify")) | first | .id // empty'
  )"

  if [[ -n "$spotify_window_id" ]]; then
    ${pkgs.niri}/bin/niri msg action move-window-to-workspace --window-id "$spotify_window_id" --focus true "$focused_workspace_ref"
    ${pkgs.niri}/bin/niri msg action focus-window --id "$spotify_window_id"
  else
    nohup ${pkgs.spotify}/bin/spotify >/dev/null 2>&1 &
  fi
''
