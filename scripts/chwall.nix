{pkgs}:
pkgs.writeShellScriptBin "chwall" ''
  wallpaper_dir=$1
  random_wallpaper=$(ls "$wallpaper_dir" | shuf -n 1)
  wallpaper_path="$wallpaper_dir/$random_wallpaper"
  ${pkgs.feh}/bin/feh --bg-scale "$wallpaper_path"
''
