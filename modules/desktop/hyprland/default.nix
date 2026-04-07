{pkgs, ...}: let
  workFirefoxCmd = "firefox -p work --name=firefox-work";
  homeFirefoxCmd = "firefox -P home --name=firefox-home";

  startApps = pkgs.writeShellScript "hyprland-start-apps" ''
    #!/usr/bin/env bash

    export PATH="${pkgs.hyprland}/bin:${pkgs.jq}/bin:$PATH"

    # Wait for kanshi to apply the monitor layout before detecting monitors.
    sleep 2

    count=$(hyprctl monitors -j | jq 'length')

    if [ "$count" -gt 1 ]; then
      ws_kitty=4
      ws_obsidian=5
      ws_ff_home=7
      ws_ff_work=7
      ws_slack=9
    else
      ws_kitty=1
      ws_obsidian=2
      ws_ff_home=3
      ws_ff_work=4
      ws_slack=5
    fi

    start_hour=8
    end_hour=17
    current_hour=$(date +%H)
    current_day=$(date +%u)

    if [ "$current_day" -ge 1 ] && [ "$current_day" -le 5 ] && [ "$current_hour" -ge "$start_hour" ] && [ "$current_hour" -lt "$end_hour" ]; then
      hyprctl dispatch exec "[workspace $ws_ff_work silent] ${workFirefoxCmd}"
      hyprctl dispatch exec "[workspace $ws_slack silent] slack"
      hyprctl dispatch exec "[workspace $ws_obsidian silent] obsidian"
    fi

    hyprctl dispatch exec "[workspace $ws_ff_home silent] ${homeFirefoxCmd}"
    hyprctl dispatch exec "[workspace $ws_kitty silent] kitty -1 -e /home/matthew/.config/bin/ta"
    hyprctl dispatch exec "[workspace special:spotify silent] spotify"
  '';

  spotifyDropdown = pkgs.writeShellScriptBin "spotify-dropdown" ''
    #!/usr/bin/env bash
    set -euo pipefail

    export PATH="${pkgs.hyprland}/bin:${pkgs.jq}/bin:$PATH"

    special_workspace="special:spotify"
    width_percent=96
    height_percent=90
    top_offset_percent=2

    get_spotify_client() {
      hyprctl clients -j | jq -c '
        first(
          .[]
          | select(.class == "Spotify" or .class == "spotify")
        ) // empty
      '
    }

    get_geometry() {
      hyprctl monitors -j | jq -r \
        --argjson widthPercent "$width_percent" \
        --argjson heightPercent "$height_percent" \
        --argjson topPercent "$top_offset_percent" '
          first(.[] | select(.focused == true)) as $monitor
          | ($monitor.width / $monitor.scale | floor) as $logicalWidth
          | ($monitor.height / $monitor.scale | floor) as $logicalHeight
          | (($logicalWidth * ($widthPercent / 100)) | floor) as $windowWidth
          | (($logicalHeight * ($heightPercent / 100)) | floor) as $windowHeight
          | ($monitor.x + (($logicalWidth - $windowWidth) / 2 | floor)) as $windowX
          | ($monitor.y + (($logicalHeight * ($topPercent / 100)) | floor)) as $windowY
          | "\($windowWidth) \($windowHeight) \($windowX) \($windowY)"
        '
    }

    is_visible() {
      hyprctl monitors -j | jq -e --arg workspace "$special_workspace" '
        any(
          .[];
          .focused == true
          and (
            (.activeSpecialWorkspace.name // .specialWorkspace.name // "") == $workspace
          )
        )
      ' >/dev/null
    }

    client="$(get_spotify_client)"
    if [ -z "$client" ]; then
      hyprctl dispatch exec "[workspace $special_workspace silent] spotify"
      for _ in $(seq 1 100); do
        sleep 0.1
        client="$(get_spotify_client)"
        if [ -n "$client" ]; then
          break
        fi
      done
    fi

    if [ -z "$client" ]; then
      exit 1
    fi

    address="$(printf '%s\n' "$client" | jq -r '.address')"
    workspace_name="$(printf '%s\n' "$client" | jq -r '.workspace.name')"
    read -r window_width window_height window_x window_y <<EOF
    $(get_geometry)
    EOF

    if [ "$workspace_name" != "$special_workspace" ]; then
      hyprctl dispatch movetoworkspacesilent "$special_workspace,address:$address"
    fi

    hyprctl dispatch resizewindowpixel "exact $window_width $window_height,address:$address"
    hyprctl dispatch movewindowpixel "exact $window_x $window_y,address:$address"

    if is_visible; then
      hyprctl dispatch togglespecialworkspace spotify
      exit 0
    fi

    hyprctl dispatch togglespecialworkspace spotify
    hyprctl dispatch focuswindow "address:$address"
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

  windowRules = [
    "float on, match:class ^(spotify|Spotify)$"
    "float on, match:class ^(signal|signal-desktop|Signal)$"
    "center on, match:class ^(signal|signal-desktop|Signal)$"
    "size 70% 70%, match:class ^(signal|signal-desktop|Signal)$"
  ];
in {
  home.packages = with pkgs; [
    fuzzel
    workspaceRouter
    rerouteScript
    spotifyDropdown
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
        special_scale_factor = 1;
        smart_split = false;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
      };

      bind =
        [
          "$mod, Return, exec, kitty -1 -e bash -c 'exec ~/.config/bin/ta || $SHELL'"
          "$mod CTRL, Return, exec, kitty -1"
          "$mod SHIFT, W, exec, ${workFirefoxCmd}"
          "$mod SHIFT, H, exec, ${homeFirefoxCmd}"
          "$mod ALT, W, exec, ~/.config/bin/chwall ~/.config/wallpapers"
          "$mod CTRL, L, exec, hyprlock"
          "$mod, Space, exec, fuzzel"
          "$mod, S, exec, ${spotifyDropdown}/bin/spotify-dropdown"
          "$mod, W, killactive"
          "$mod, M, exit"
          "$mod, E, exec, dolphin"
          "$mod, V, togglefloating"
          "$mod, R, exec, fuzzel --dmenu"
          "$mod, B, exec, oor-bw-pw"
          "$mod, P, exec, hyprshot -m region -z"
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
          "$mod SHIFT, P, exec, hyprshot -m region -z --clipboard-only"
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
        ++ workspaceKeyBinds;

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
