{ pkgs }:
pkgs.writeShellScriptBin "oor-bw-pw" ''
  pw="$(${pkgs.bitwarden-cli}/bin/bw get password bitwarden.com)"
  copied=0
  if [ -n "$WAYLAND_DISPLAY" ] && command -v ${pkgs.wl-clipboard}/bin/wl-copy >/dev/null; then
    printf "%s" "$pw" | ${pkgs.wl-clipboard}/bin/wl-copy
    copied=1
  elif [ -n "$DISPLAY" ] && command -v ${pkgs.xclip}/bin/xclip >/dev/null; then
    printf "%s" "$pw" | ${pkgs.xclip}/bin/xclip -selection clipboard
    copied=1
  fi

  if [ "$copied" = "1" ]; then
    if command -v ${pkgs.dunst}/bin/dunstify >/dev/null; then
      ${pkgs.dunst}/bin/dunstify "Copied password to clipboard"
    else
      echo "Copied password to clipboard"
    fi
  else
    echo "No suitable clipboard manager found (need wl-copy or xclip)."
    exit 1
  fi
''
