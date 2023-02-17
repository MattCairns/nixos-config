{ config
, pkgs
, ...
}: {
  services.betterlockscreen = {
    enable = true;
    arguments = [ "blur" ];
  };
}
