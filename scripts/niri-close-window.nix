{pkgs}:
pkgs.writeShellScriptBin "niri-close-window" ''
  : "''${SPOTIFY_WORKSPACE:=10}"
  spotify_workspace="$SPOTIFY_WORKSPACE"
  focused_window="$(${pkgs.niri}/bin/niri msg -j focused-window 2>/dev/null || true)"

  if [[ -z "$focused_window" || "$focused_window" == "null" ]]; then
    exit 0
  fi

  app_id="$(${pkgs.jq}/bin/jq -r '.app_id // ""' <<<"$focused_window")"
  window_id="$(${pkgs.jq}/bin/jq -r '.id // empty' <<<"$focused_window")"

  if [[ "$app_id" == "spotify" && -n "$window_id" ]]; then
    ${pkgs.niri}/bin/niri msg action move-window-to-workspace --window-id "$window_id" --focus false "$spotify_workspace"
  else
    ${pkgs.niri}/bin/niri msg action close-window
  fi
''
