{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };

  xdg.configFile."waybar".source = ./config;
}
