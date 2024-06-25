{pkgs}:
pkgs.writeShellScriptBin "chwall" ''
  wallpaper_dir=$1
  if command -v ${pkgs.swww}/bin/swww >/dev/null 2>&1; then
      random_wallpaper=$(ls "$wallpaper_dir" | shuf -n 1)
     ${pkgs.swww}/bin/swww img "$wallpaper_dir/$random_wallpaper"
  fi
''
