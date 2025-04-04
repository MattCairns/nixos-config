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
    swww
    kanshi
    hyprcursor
  ];

  programs.hyprlock.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        before_sleep_cmd = "loginctl lock-session";
        ignore_dbus_inhibit = false;
        lock_cmd = "pidof hyprlock || hyprlock";
      };

      listener = [
        {
          timeout = 150;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 300;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

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
  xdg.configFile."hypr/hyprlock.conf".source = ./config/hyprlock.conf;
  xdg.configFile."hypr/start-apps.sh".source = ./config/start-apps.sh;
  xdg.configFile."hypr/toggle-tailscale.sh".source = ./config/toggle-tailscale.sh;
}
