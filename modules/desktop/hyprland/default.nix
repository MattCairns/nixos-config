{
  config,
  pkgs,
  machine,
  ...
}: {
  home.packages = with pkgs; [
    wofi
    hyprpaper
    wlr-randr
    swaylock
    swayidle
    slurp
    xwayland
    waybar
  ];

  services.swayidle = {
    enable = true;
  };

  xdg.configFile."hypr/hyprland.conf".source = ./config/hyprland.conf;
  xdg.configFile."hypr/machine.conf".source = ./config/${machine}.conf;

  xdg.configFile."hypr/hyprpaper.conf".source = ./config/hyprpaper.conf;
}
