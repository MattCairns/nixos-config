{ config
, pkgs
, user
, ...
}: {
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
