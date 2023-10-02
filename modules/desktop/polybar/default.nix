{pkgs, ...}: {
  services.polybar = {
    enable = true;
    package = pkgs.polybarFull;
    script = "";
  };

  xdg.configFile."polybar".source = ./config;
}
