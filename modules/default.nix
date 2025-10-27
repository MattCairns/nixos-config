{ ... }:
{
  imports =
    # [(import ../modules/dev/neovim)]
    [ (import ../modules/dev/nixvim) ]
    ++ [ (import ../modules/dev/git) ]
    ++ [ (import ../modules/dev/kitty) ]
    # ++ [ (import ../modules/dev/ghostty) ]
    ++ [ (import ../modules/dev/wezterm) ]
    ++ [ (import ../modules/dev/starship) ]
    ++ [ (import ../modules/dev/tmux) ]
    ++ [ (import ../modules/dev/fish) ]
    ++ [ (import ../modules/dev/direnv) ]
    ++ [ (import ../modules/desktop/waybar) ]
    # ++ [(import ../modules/desktop/hyprland)]
    ++ [ (import ../modules/desktop/bspwm) ]
    ++ [ (import ../modules/desktop/polybar) ]
    ++ [ (import ../modules/apps/firefox) ];
}
