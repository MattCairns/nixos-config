{pkgs}:
pkgs.writeShellScriptBin "chwall" ''
  # Noctalia owns the wallpaper on Wayland. With a directory argument, pick a
  # random image from it; otherwise use Noctalia's configured directory.
  if [ -n "''${1:-}" ]; then
    wallpaper_path=$(${pkgs.findutils}/bin/find "$1" -maxdepth 1 -type f | ${pkgs.coreutils}/bin/shuf -n 1)
    exec noctalia msg wallpaper-set "$wallpaper_path"
  fi
  exec noctalia msg wallpaper-random
''
