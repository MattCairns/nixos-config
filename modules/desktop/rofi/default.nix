{pkgs, ...}: {
  programs = {
    rofi = {
      enable = true;
      extraConfig = {
      };
      theme = config/tokyonight.rasi;
      plugins = [
        pkgs.rofi-calc
        pkgs.rofi-top
      ];
    };
  };
}
