{ config
, pkgs
, ...
}: {
  programs = {
    rofi = {
      enable = true;
      theme = "gruvbox-dark-hard";
    };
  };
}
