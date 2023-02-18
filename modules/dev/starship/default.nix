{ config
, pkgs
, user
, ...
}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
