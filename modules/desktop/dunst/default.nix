{ config
, pkgs
, ...
}: {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 5;
        frame_color = "#eceff1";
        corner_radius = 10;
      };
      urgency_normal = {
        background = "#181818";
        foreground = "#dfdfdf";
        timeout = 10;
      };
    };
  };
}
