{pkgs}:
pkgs.writeShellScriptBin "chwall" ''
  wallpaper_dir=$1
  if command -v ${pkgs.hyprpaper}/bin/hyprctl >/dev/null 2>&1; then
      random_wallpaper=$(ls "$wallpaper_dir" | shuf -n 1)
      wallpaper_path="$wallpaper_dir/$random_wallpaper"
      
      # Preload the wallpaper first
      ${pkgs.hyprland}/bin/hyprctl hyprpaper preload "$wallpaper_path"
      
      # Set the wallpaper
      ${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper ",$wallpaper_path"
  fi
''
