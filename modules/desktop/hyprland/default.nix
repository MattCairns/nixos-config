{
  pkgs,
  machine,
  ...
}: {
  home.packages = with pkgs; [
    hyprpaper
    wlr-randr
    swayidle
    xwayland
    slurp
    wofi
  ];

  programs.wlogout = {
    enable = true;
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    # nvidiaPatches = true;
    extraConfig = builtins.readFile ./config/hyprland.conf;
  };

  # xdg.configFile."hypr/hyprland.conf".source = ./config/hyprland.conf;
  xdg.configFile."hypr/machine.conf".source = ./config/${machine}.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ./config/hyprpaper.conf;
  xdg.configFile."hypr/start-apps.sh".source = ./config/start-apps.sh;
  xdg.configFile."hypr/start-swaylock.sh".source = ./config/start-swaylock.sh;
}
