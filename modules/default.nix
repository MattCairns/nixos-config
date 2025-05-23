{...}: {
  imports =
    # [(import ../modules/dev/neovim)]
    [(import ../modules/dev/nixvim)]
    ++ [(import ../modules/dev/git)]
    ++ [(import ../modules/dev/kitty)]
    ++ [(import ../modules/dev/wezterm)]
    ++ [(import ../modules/dev/starship)]
    ++ [(import ../modules/dev/tmux)]
    ++ [(import ../modules/dev/fish)]
    ++ [(import ../modules/dev/direnv)]
    ++ [(import ../modules/desktop/waybar)]
    ++ [(import ../modules/desktop/hyprland)]
    ++ [(import ../modules/apps/firefox)];
}
