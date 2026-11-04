{pkgs}:
pkgs.writeShellScriptBin "oor-bw-pw" ''
  notify() { ${pkgs.libnotify}/bin/notify-send "Bitwarden" "$1"; }

  # Keybinds don't inherit fish's BW_SESSION, so read the sops secret directly.
  session_file="''${XDG_CONFIG_HOME:-$HOME/.config}/sops-nix/secrets/bitwarden-session-key"
  if ! pw="$(BW_SESSION="$(cat "$session_file")" ${pkgs.bitwarden-cli}/bin/bw get password bitwarden.com)" || [ -z "$pw" ]; then
    notify "Failed to get password"
    exit 1
  fi

  if [ -n "$WAYLAND_DISPLAY" ]; then
    printf "%s" "$pw" | ${pkgs.wl-clipboard}/bin/wl-copy
  elif [ -n "$DISPLAY" ]; then
    printf "%s" "$pw" | ${pkgs.xclip}/bin/xclip -selection clipboard
  else
    echo "No display to copy to (need Wayland or X11)."
    exit 1
  fi
  notify "Copied password to clipboard"
''
