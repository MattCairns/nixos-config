{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    pywal
    calc
    networkmanager_dmenu
  ];

  xdg.configFile."bspwm".source = ./config;
}
