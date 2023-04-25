{ pkgs
, ...
}: {
  programs = {
    rofi = {
      enable = true;
      theme = "gruvbox-dark-hard";
      plugins = [
        pkgs.rofi-calc
        pkgs.rofi-top
      ];
    };
  };
}
