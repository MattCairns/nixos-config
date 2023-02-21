{ config
, pkgs
, ...
}: {
  services.picom = {
    enable = true;
    menuOpacity = 0.8;
    fade = true;
    fadeDelta = 10;
    fadeSteps = [ 0.03 0.03 ];
    backend = "xrender";
    vSync = true;
    shadow = true;
  };
}
