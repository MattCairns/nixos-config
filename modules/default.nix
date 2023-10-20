{...}: {
  imports =
    [(import ../modules/dev/neovim)]
    ++ [(import ../modules/dev/git)]
    ++ [(import ../modules/dev/kitty)]
    ++ [(import ../modules/dev/wezterm)]
    ++ [(import ../modules/dev/starship)]
    ++ [(import ../modules/dev/tmux)]
    ++ [(import ../modules/dev/fish)]
    ++ [(import ../modules/dev/direnv)]
    ++ [(import ../modules/desktop/bspwm)]
    ++ [(import ../modules/desktop/sxhkd)]
    ++ [(import ../modules/desktop/polybar)]
    ++ [(import ../modules/desktop/rofi)]
    ++ [(import ../modules/desktop/picom)]
    ++ [(import ../modules/desktop/dunst)]
    ++ [(import ../modules/desktop/betterlockscreen)]
    ++ [(import ../modules/desktop/hyprland)]
    ++ [(import ../modules/apps/firefox)];
}
