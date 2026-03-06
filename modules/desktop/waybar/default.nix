{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.override {niriSupport = true;};
  };

  xdg.configFile."waybar/config".source = ./config/config;
  xdg.configFile."waybar/mocha.css".source = ./config/mocha.css;
  xdg.configFile."waybar/style.css".source = ./config/style.css;
}
