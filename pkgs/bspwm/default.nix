{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    polybarFull
    pywal
    calc
    networkmanager_dmenu
  ];

  xdg.configFile."bspwm".source = config/bspwm;
}
