{ pkgs, ... }: {
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
    settings = {
      default-timeout = 5000;
      background-color = "#0d0d0d";
      text-color = "#ffffff";
      border-color = "#33ccff";
    };
  };
}
