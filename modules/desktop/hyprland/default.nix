{
  pkgs,
  machine,
  ...
}: {
  home.packages = with pkgs; [
    hyprpaper
    wlr-randr
    xwayland
    slurp
    wl-clipboard
    swayidle
    swww
    kanshi
    hyprcursor
  ];

  services.dunst = {
    enable = true;
    package = pkgs.dunst;
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

  programs.wlogout = {
    enable = true;
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-fancy;
  };

  programs.wofi = {
    enable = true;
    style =
      /*
      css
      */
      ''
        *{
            font-family: monospace;
        }

        window {
            margin: 5px;
            border: 0px solid white;
            background-color: rgba(48, 98, 148, 1.0);
        }

        #input {
            margin: 5px;
            border-radius: 0px;
            border: none;
            border-bottom: 0px solid black;
            background-color: #1A1C1E;
            color: white;
        }

        #inner-box {
            margin: 5px;
            background-color: #1A1C1E;
        }

        #outer-box {
            margin: 5px;
            padding:10px;
            background-color: #1A1C1E;
        }

        #scroll {

        }

        #text {
            margin: 5px;
            color: white;
            /* border: 2px solid cyan; */
            /* background-color: cyan; */
        }

        /* #entry:nth-child(even){
            background-color: #404552;
        } */

        #entry:selected {
            background-color: #151718;
        }

        #text:selected {
            text-decoration-color: white;
        }
      '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    extraConfig = builtins.readFile ./config/hyprland.conf;
  };

  xdg.configFile."hypr/machine.conf".source = ./config/${machine}.conf;
  # xdg.configFile."hypr/hyprpaper.conf".source = ./config/hyprpaper.conf;
  xdg.configFile."hypr/start-apps.sh".source = ./config/start-apps.sh;
  xdg.configFile."hypr/start-swaylock.sh".source = ./config/start-swaylock.sh;
  xdg.configFile."hypr/toggle-tailscale.sh".source = ./config/toggle-tailscale.sh;
}
