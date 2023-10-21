{
  pkgs,
  machine,
  ...
}: {
  home.packages = with pkgs; [
    wofi
    hyprpaper
    wlr-randr
    swayidle
    slurp
    xwayland
  ];

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
  };

  services.swayidle = {
    enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    # nvidiaPatches = true;
    extraConfig = builtins.readFile ./config/hyprland.conf;
  };

  # xdg.configFile."hypr/hyprland.conf".source = ./config/hyprland.conf;
  xdg.configFile."hypr/machine.conf".source = ./config/${machine}.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ./config/hyprpaper.conf;
}
