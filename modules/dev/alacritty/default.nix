{ config
, pkgs
, user
, ...
}: {
  programs.alacritty = {
    enable = true;
    settings = {
      padding = {
        x = 10;
        y = 10;
      };
      font = {
        normal = {
          family = "FiraCode Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "FiraCode Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font Mono";
          style = "Italic";
        };
      };

      colors = {
        primary = {
          background = "0x1f1f28";
          foreground = "0xdcd7ba";
        };
        normal = {
          black = "0x090618";
          red = "0xc34043";
          green = "0x76946a";
          yellow = "0xc0a36e";
          blue = "0x7e9cd8";
          magenta = "0x957fb8";
          cyan = "0x6a9589";
          white = "0xc8c093";
        };
        bright = {
          black = "0x727169";
          red = "0xe82424";
          green = "0x98bb6c";
          yellow = "0xe6c384";
          blue = "0x7fb4ca";
          magenta = "0x938aa9";
          cyan = "0x7aa89f";
          white = "0xdcd7ba";
        };
        selection = {
          background = "0x2d4f67";
          foreground = "0xc8c093";
        };
        "indexed_colors" =
          [{
            index = 16;
            color = "0xffa066";
          }
            {
              index = 17;
              color = "0xff5d62";
            }];
      };
    };
  };
}
