{ pkgs, ... }: {
  programs.niri.enable = true;

  home.packages = with pkgs; [
    fuzzel
    swaylock
    swaybg
    wlogout
    mako
    xdg-utils
  ];

  xdg.configFile."niri/config.kdl".source = ./config.kdl;
  xdg.configFile."waybar/niri-config.jsonc".source = ./waybar/config.jsonc;
  xdg.configFile."waybar/niri-style.css".source = ./waybar/style.css;

  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    backgroundColor = "#0d0d0d";
    textColor = "#ffffff";
    borderColor = "#33ccff";
  };
}
