{pkgs, ...}: {
  home.packages = with pkgs; [
    fuzzel
    swaylock
    swaybg
    wlogout
    mako
    xdg-utils
  ];

  xdg.configFile."niri/config.kdl".source = ./config.kdl;
  xdg.configFile."waybar/niri-config.jsonc".source = ./waybar/config.jsonc;
  xdg.configFile."waybar/niri-style.css".source = ./waybar/style.css;

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      background-color = "#1f2335";
      text-color = "#a9b1d6";
      border-color = "#7a88cf";
    };
  };

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "2256x1504";
            scale = 1.25;
            position = "0,1224";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "2256x1504";
            scale = 1.25;
            position = "0,1224";
            status = "enable";
          }
          {
            criteria = "ASUSTek COMPUTER INC PA278CV LCLMQS261918";
            mode = "2560x1440";
            position = "2256,560";
            status = "enable";
          }
          {
            criteria = "ASUSTek COMPUTER INC PA278QV LBLMQS297570";
            mode = "2560x1440";
            transform = "270";
            position = "4816,0";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "fallback";
        profile.outputs = [
          {
            criteria = "eDP-1";
            scale = 1.25;
            status = "enable";
          }
          {
            criteria = "*";
            status = "enable";
          }
        ];
      }
    ];
  };
}
