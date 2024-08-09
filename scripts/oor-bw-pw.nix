{pkgs}:
pkgs.writeShellScriptBin "oor-bw-pw"
/*
bash
*/
''
  ${pkgs.bitwarden-cli}/bin/bw get password bitwarden.com | ${pkgs.wl-clipboard}/bin/wl-copy
  ${pkgs.dunst}/bin/dunstify "Copied password to clipboard"
''
