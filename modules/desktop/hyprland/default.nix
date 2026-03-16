{
  pkgs,
  machine,
  lib,
  ...
}: let
  defaultWorkspaceMap = {
    firefoxWork = "7";
    firefoxHome = "7";
    slack = "9";
    kitty = "4";
    obsidian = "";
    spotify = "10";
  };

  perMachineWorkspace = {
    framework =
      defaultWorkspaceMap
      // {
        obsidian = "5";
      };
  };

  workspaceMap = defaultWorkspaceMap // lib.attrByPath [machine] {} perMachineWorkspace;

  workFirefoxCmd = "firefox -p work --name=firefox-work";
  homeFirefoxCmd = "firefox -P home --name=firefox-home";

  startApps = pkgs.writeShellScript "hyprland-start-apps" ''
    #!/usr/bin/env bash

    start_hour=8
    end_hour=17

    current_hour=$(date +%H)
    current_day=$(date +%u)

    if [ "$current_day" -ge 1 ] && [ "$current_day" -le 5 ] && [ "$current_hour" -ge "$start_hour" ] && [ "$current_hour" -lt "$end_hour" ]; then
      ${workFirefoxCmd} &
      slack --disable-gpu &
      obsidian &
    fi

    ${homeFirefoxCmd} &
    kitty -e /home/matthew/.config/bin/ta &
    spotify &
  '';

  lockCmd = "${pkgs.procps}/bin/pidof hyprlock || hyprlock";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  externalMonitorOne = "desc:ASUSTek COMPUTER INC PA278CV LCLMQS261918";
  externalMonitorTwo = "desc:ASUSTek COMPUTER INC PA278QV LBLMQS297570";

  workspaceRouter = pkgs.callPackage ../../../scripts/hypr-workspace-router.nix {
    inherit externalMonitorOne externalMonitorTwo;
  };

  rerouteScript = pkgs.writeShellScriptBin "hypr-reroute" ''
    count=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq 'length')
    if [ "$count" -eq 1 ]; then
      exec "${workspaceRouter}/bin/hypr-workspace-router" undocked
    else
      exec "${workspaceRouter}/bin/hypr-workspace-router" docked
    fi
  '';

  workspaceKeyBinds = builtins.concatLists (
    builtins.genList (
      i: let
        ws =
          if i == 9
          then "10"
          else toString (i + 1);
        key =
          if i == 9
          then "0"
          else toString (i + 1);
      in [
        "$mod, ${key}, workspace, ${ws}"
        "$mod SHIFT, ${key}, movetoworkspace, ${ws}"
      ]
    )
    10
  );

  spotifyBindings =
    if workspaceMap.spotify != ""
    then [
      "$mod, S, workspace, ${workspaceMap.spotify}"
      "$mod SHIFT, S, movetoworkspace, ${workspaceMap.spotify}"
    ]
    else ["$mod, S, workspace, +1"];

  workspaceRules = [
    "1, monitor:eDP-1, default:true"
    "2, monitor:eDP-1"
    "3, monitor:eDP-1"
    "4, monitor:${externalMonitorOne}, default:true"
    "5, monitor:${externalMonitorOne}"
    "6, monitor:${externalMonitorOne}"
    "7, monitor:${externalMonitorTwo}, default:true"
    "8, monitor:${externalMonitorTwo}"
    "9, monitor:${externalMonitorTwo}"
    "10, monitor:${externalMonitorTwo}"
  ];

  windowRules =
    [
      "float on, match:class ^(spotify|Spotify)$"
      "center on, match:class ^(spotify|Spotify)$"
      "float on, match:class ^(signal|signal-desktop|Signal)$"
      "center on, match:class ^(signal|signal-desktop|Signal)$"
      "size 70% 70%, match:class ^(signal|signal-desktop|Signal)$"
    ]
    ++ lib.optionals (workspaceMap.firefoxWork != "") [
      "workspace ${workspaceMap.firefoxWork} silent, match:class ^(firefox-work)$"
    ]
    ++ lib.optionals (workspaceMap.firefoxHome != "") [
      "workspace ${workspaceMap.firefoxHome} silent, match:class ^(firefox-home)$"
    ]
    ++ lib.optionals (workspaceMap.slack != "") [
      "workspace ${workspaceMap.slack} silent, match:class ^(Slack|slack)$"
    ]
    ++ lib.optionals (workspaceMap.kitty != "") [
      "workspace ${workspaceMap.kitty} silent, match:class ^(kitty)$"
    ]
    ++ lib.optionals (workspaceMap.obsidian != "") [
      "workspace ${workspaceMap.obsidian} silent, match:class ^(obsidian|Obsidian)$"
    ]
    ++ lib.optionals (workspaceMap.spotify != "") [
      "workspace ${workspaceMap.spotify} silent, match:class ^(spotify|Spotify)$"
    ];
in {
  home.packages = with pkgs; [
    fuzzel
    workspaceRouter
    rerouteScript
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    xwayland.enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
    };
    settings = {
      "$mod" = "SUPER";

      monitor = [", preferred, auto, 1"];

      exec-once = [
        "${startApps}"
      ];

      env = [
        "NIXOS_OZONE_WL,1"
        "MOZ_ENABLE_WAYLAND,1"
        "QT_QPA_PLATFORM,wayland"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
      };

      general = {
        border_size = 2;
        gaps_in = 8;
        gaps_out = 8;
        layout = "dwindle";
        resize_on_border = true;
        "col.active_border" = "rgb(7a88cf)";
        "col.inactive_border" = "rgb(4b517a)";
      };

      decoration = {
        rounding = 0;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 15;
          render_power = 2;
          color = "rgba(181b2a40)";
        };
        blur.enabled = false;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        smart_split = false;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
      };

      bind =
        [
          "$mod, Return, exec, kitty -e bash -c 'exec ~/.config/bin/ta || $SHELL'"
          "$mod CTRL, Return, exec, kitty"
          "$mod CTRL, W, exec, ${workFirefoxCmd}"
          "$mod CTRL, H, exec, ${homeFirefoxCmd}"
          "$mod ALT, W, exec, ~/.config/bin/chwall ~/.config/wallpapers"
          "$mod CTRL, L, exec, hyprlock"
          "$mod, Space, exec, fuzzel"
          "$mod, W, killactive"
          "$mod, M, exit"
          "$mod, E, exec, dolphin"
          "$mod, V, togglefloating"
          "$mod, R, exec, fuzzel --dmenu"
          "$mod, B, exec, oor-bw-pw"
          "$mod, P, pseudo"
          "$mod CTRL, left, focusmonitor, l"
          "$mod CTRL, right, focusmonitor, r"
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, B, exec, bluetoothctl connect 88:C9:E8:44:61:64"
          "$mod SHIFT, D, exec, ${pkgs.systemd}/bin/systemctl --user restart kanshi.service"
          "$mod SHIFT, R, exec, ${rerouteScript}/bin/hypr-reroute"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86Display, exec, ${hyprctl} dispatch dpms off"
          ", XF86WLAN, exec, nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ]
        ++ workspaceKeyBinds
        ++ spotifyBindings;

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      workspace = workspaceRules;
      windowrule = windowRules;
    };
  };

  programs.hyprlock = {
    enable = true;
    extraConfig = ''
      general {
          disable_loading_bar = true
          hide_cursor = false
          grace = 2
          no_fade_in = false
      }

      background {
          monitor =
          path = /home/matthew/.config/wallpapers/pexels-eberhard-grossgasteiger-730981.jpg
          blur_passes = 2
          blur_size = 6
      }

      input-field {
          monitor =
          size = 280, 56
          outline_thickness = 2
          dots_size = 0.22
          dots_spacing = 0.2
          dots_center = true
          outer_color = rgb(7a88cf)
          inner_color = rgb(1f2335)
          font_color = rgb(a9b1d6)
          fade_on_empty = false
          placeholder_text = <span foreground="#a9b1d6">Password...</span>
          position = 0, -40
          halign = center
          valign = center
      }

      label {
          monitor =
          text = cmd[update:1000] echo "$(date +'%H:%M')"
          color = rgb(a9b1d6)
          font_size = 88
          font_family = JetBrainsMono Nerd Font
          position = 0, 140
          halign = center
          valign = center
      }

      label {
          monitor =
          text = cmd[update:1000] echo "$(date +'%A, %d %B')"
          color = rgb(7a88cf)
          font_size = 18
          font_family = JetBrainsMono Nerd Font
          position = 0, 70
          halign = center
          valign = center
      }
    '';
  };

  services.hypridle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = {
      general = {
        lock_cmd = lockCmd;
        before_sleep_cmd = lockCmd;
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
      };
      listener = [
        {
          timeout = 300;
          on-timeout = lockCmd;
        }
        {
          timeout = 420;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
      ];
    };
  };
}
