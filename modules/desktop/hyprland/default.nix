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

  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock";
      }
      {
        event = "lock";
        command = "lock";
      }
    ];

    timeouts = [
      {
        timeout = 60;
        command = "${pkgs.swaylock}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 3 --effect-blur 8x10 --effect-vignette 0.5:0.5 --ring-color 1a1b26 --key-hl-color 96be25 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --fade-in 1";
      }
    ];
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
}
