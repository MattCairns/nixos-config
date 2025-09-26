{
  pkgs,
  machine,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    hyprpaper
    wlr-randr
    xwayland
    slurp
    wl-clipboard
    kanshi
    hyprcursor
  ];

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = "/home/matthew/.config/wallpapers/pexels-eberhard-grossgasteiger-730981.jpg";
      wallpapers = ",/home/matthew/.config/wallpapers/pexels-eberhard-grossgasteiger-730981.jpg";
    };
    package = inputs.hyprpaper.packages.${pkgs.system}.default;
  };

  programs.hyprlock.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "sleep 3; hyprctl dispatch dpms on";
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
          on-resume = "sleep 3; hyprctl dispatch dpms on";
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
      # css
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

    settings = {
      env = [
        "NIXOS_OZONE_WL,1"
        "HYPRCURSOR_THEME,phinger-cursors-light"
        "HYPRCURSOR_SIZE,32"
      ];

      "exec-once" = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "hyprpaper"
        "waybar"
        "dunst"
        "hypridle"
        "~/.config/hypr/start-apps.sh"
      ];

      misc = {
        disable_hyprland_logo = true;
      };

      input = {
        kb_layout = "us,us";
        kb_variant = ",colemak";
        kb_options = "grp:shifts_toggle";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = false;
        };
      }
      // (
        if machine == "framework" || machine == "laptop" then
          {
            kb_options = "caps:swapescape,grp:shifts_toggle";
          }
        else
          { }
      );

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 5;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      windowrulev2 = [
        "float,class:^(*.)$,title:^(Automated Test Platform)$"
      ];

      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, Return, exec, ghostty --command ~/.config/bin/ta"
        "$mainMod + CONTROL, Return, exec, ghostty"
        "$mainMod + SHIFT, W, exec, firefox -p work"
        "$mainMod + SHIFT, H, exec, firefox -P home"
        "$mainMod + ALT, W, exec, ~/.config/bin/chwall ~/.config/wallpapers"
        "$mainMod, S, togglespecialworkspace, spotify"
        "$mainMod + SHIFT, L, exec, hyprlock"
        "$mainMod + CONTROL, B, exec, killall -r waybar && waybar"
        "$mainMod, Space, exec, pkill wofi || wofi --show=drun --prompt=\"\" --hide-scroll --insensitive --columns=2 --allow-images"
        "$mainMod, W, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, dolphin"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, wofi --show drun"
        "$mainMod, B, exec, oor-bw-pw"
        "$mainMod, P, pseudo,"
        "$mainMod CTRL, left, movecurrentworkspacetomonitor, l"
        "$mainMod CTRL, right, movecurrentworkspacetomonitor, r"

        # Movement
        "$mainMod, h, movefocus, l"
        "$mainMod, j, movefocus, d"
        "$mainMod, k, movefocus, u"
        "$mainMod, l, movefocus, r"

        # Workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Mouse workspace switching
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Bluetooth
        "$mainMod SHIFT, b, exec, bluetoothctl connect 88:C9:E8:44:61:64"

        # Special keys
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86WLAN, exec, nmcli radio wifi | grep -q \"enabled\" && nmcli radio wifi off || nmcli radio wifi on"
        ", XF86Display, exec, hyprctl dispatch dpms toggle"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Machine-specific monitor and workspace configuration
      monitor =
        if machine == "framework" then
          [
            "desc:ASUSTek COMPUTER INC PA278QV LBLMQS297570,2560x1440@59.951,4439x0,1.0"
            "desc:ASUSTek COMPUTER INC PA278QV LBLMQS297570,transform,3"
            "desc:ASUSTek COMPUTER INC PA278CV LCLMQS261918,2560x1440@59.951,1879x608,1.0"
            "eDP-1,2256x1504@59.999001,0x1306,1.175"
          ]
        else if machine == "laptop" then
          [
            "eDP-1,1920x1080@60.033001,0x1376,1.0"
            "DP-6,2560x1440@59.951,4480x0,1.0"
            "DP-6,transform,1"
            "DP-5,2560x1440@59.951,1920x599,1.0"
          ]
        else if machine == "nuc" then
          [
            "HDMI-A-5,highres,1920x560,auto"
            "DP-6,highres,4480x0,auto"
            "DP-6,transform,3"
          ]
        else
          [ ];

      workspace =
        if machine == "framework" then
          [
            "1, monitor:eDP-1, default:true"
            "2, monitor:eDP-1, default:true"
            "3, monitor:eDP-1, default:true"
            "4, monitor:desc:ASUSTek COMPUTER INC PA278CV LCLMQS261918, default:true"
            "5, monitor:desc:ASUSTek COMPUTER INC PA278CV LCLMQS261918, default:true"
            "6, monitor:desc:ASUSTek COMPUTER INC PA278CV LCLMQS261918, default:true"
            "7, monitor:desc:ASUSTek COMPUTER INC PA278QV LBLMQS297570, default:true"
            "8, monitor:desc:ASUSTek COMPUTER INC PA278QV LBLMQS297570, default:true"
            "9, monitor:desc:ASUSTek COMPUTER INC PA278QV LBLMQS297570, default:true"
          ]
        else if machine == "laptop" then
          [
            "1,monitor:eDP-1,default:true"
            "2,monitor:eDP-1"
            "3,monitor:eDP-1"
            "4,monitor:eDP-1"
            "5,monitor:eDP-1"
          ]
        else if machine == "nuc" then
          [
            "4, monitor:HDMI-A-5"
            "5, monitor:HDMI-A-5"
            "6, monitor:HDMI-A-5"
            "7, monitor:DP-6"
            "8, monitor:DP-6"
            "9, monitor:DP-6"
          ]
        else
          [ ];

      device =
        if machine == "framework" then
          [
            {
              name = "at-translated-set-2-keyboard";
              kb_options = "caps:swapescape";
            }
          ]
        else
          [ ];
    };
  };

  xdg.configFile."hypr/hyprlock.conf".source = ./config/hyprlock.conf;
  xdg.configFile."hypr/start-apps.sh".source = ./config/start-apps.sh;
  xdg.configFile."hypr/toggle-tailscale.sh".source = ./config/toggle-tailscale.sh;
}
