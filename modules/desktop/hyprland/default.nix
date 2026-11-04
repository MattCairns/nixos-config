{
  config,
  lib,
  pkgs,
  ...
}: let
  workFirefoxCmd = "firefox-work"; # wrapper from config/home.nix
  homeFirefoxCmd = "firefox -P home --name=firefox-home";
  noctalia = lib.getExe config.programs.noctalia.package;

  # Hyprland >= 0.57 only reads Lua config; `hyprctl dispatch` takes a Lua
  # dispatcher expression and `hyprctl eval` runs Lua (`hyprctl keyword` is gone).
  toLua = lib.generators.toLua {multiline = false;};
  lua = lib.generators.mkLuaInline;

  # App workspaces when docked (both externals) and undocked. Used at startup and
  # by the workspace router; classes are the window classes to migrate.
  layout = {
    kitty = {
      classes = ["kitty"];
      docked = 4;
      undocked = 1;
    };
    obsidian = {
      classes = ["Obsidian" "obsidian"];
      docked = 5;
      undocked = 2;
    };
    ffHome = {
      classes = ["firefox-home"];
      docked = 7;
      undocked = 3;
    };
    ffWork = {
      classes = ["firefox-work"];
      docked = 7;
      undocked = 4;
    };
    slack = {
      classes = ["Slack" "slack"];
      docked = 9;
      undocked = 5;
    };
  };
  # Counting externals rather than all monitors stays correct with eDP-1 disabled.
  countExternals = ''hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")] | length' '';
  wsVars = profile: lib.concatStrings (lib.mapAttrsToList (app: ws: "ws_${app}=${toString ws.${profile}}\n") layout);

  startApps = pkgs.writeShellScript "hyprland-start-apps" ''
    #!/usr/bin/env bash

    export PATH="${pkgs.hyprland}/bin:${pkgs.jq}/bin:$PATH"

    # Usage: exec_on <workspace> <command>; the command must not contain double quotes.
    exec_on() {
      hyprctl dispatch "hl.dsp.exec_cmd(\"$2\", { workspace = \"$1 silent\" })"
    }

    externals=$(${countExternals})

    if [ "$externals" -ge 2 ]; then
      ${wsVars "docked"}
    else
      ${wsVars "undocked"}
    fi

    start_hour=8
    end_hour=17
    current_hour=$(date +%H)
    current_day=$(date +%u)

    if [ "$current_day" -ge 1 ] && [ "$current_day" -le 5 ] && [ "$current_hour" -ge "$start_hour" ] && [ "$current_hour" -lt "$end_hour" ]; then
      exec_on "$ws_ffWork" "${workFirefoxCmd}"
      exec_on "$ws_slack" "slack"
      exec_on "$ws_obsidian" "obsidian"
    fi

    exec_on "$ws_ffHome" "${homeFirefoxCmd}"
    exec_on "$ws_kitty" "kitty -1 -e ${config.xdg.configHome}/bin/ta"
  '';

  # Manual and pre-sleep locks require the password immediately (grace = 0 in
  # hyprlock's config); only the idle-timeout lock gets a grace period.
  lockCmd = "${pkgs.procps}/bin/pidof hyprlock || hyprlock";
  idleLockCmd = "${pkgs.procps}/bin/pidof hyprlock || hyprlock --grace 5";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  # Usage: hypr-dpms on|off
  dpms = pkgs.writeShellScript "hypr-dpms" ''
    exec ${pkgs.hyprland}/bin/hyprctl dispatch "hl.dsp.dpms({ action = \"$1\" })"
  '';
  dpmsOffCmd = "${dpms} off";
  dpmsOnCmd = "${dpms} on";
  externalMonitorOne = "desc:ASUSTek COMPUTER INC PA278CV LCLMQS261918";
  externalMonitorTwo = "desc:ASUSTek COMPUTER INC PA278QV LBLMQS297570";
  laptopMonitor = {
    output = "eDP-1";
    mode = "2256x1504";
    position = "0x1224";
    scale = "1.175";
  };

  workspaceRouter = pkgs.callPackage ../../../scripts/hypr-workspace-router.nix {
    inherit externalMonitorOne externalMonitorTwo layout workspaceRules countExternals;
  };
  routerBin = "${workspaceRouter}/bin/hypr-workspace-router";

  # Re-run the workspace router whenever a monitor is plugged or unplugged.
  monitorWatcher = pkgs.writeShellScript "hypr-monitor-watcher" ''
    sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$sock" | while IFS= read -r line; do
      case "$line" in
        "monitoraddedv2>>"* | "monitorremovedv2>>"*) ${routerBin} & ;;
      esac
    done
  '';

  # With the lid closed while docked, turn the laptop panel off instead of
  # suspending (logind ignores the lid when docked). Undocked, logind suspends.
  # hl.monitor merges into the existing rule for the output.
  lidSwitch = pkgs.writeShellScript "hypr-lid-switch" ''
    export PATH="${pkgs.hyprland}/bin:${pkgs.jq}/bin:$PATH"
    case "$1" in
      close)
        externals=$(${countExternals})
        if [ "$externals" -gt 0 ]; then
          hyprctl eval ${lib.escapeShellArg "hl.monitor(${toLua {
      output = "eDP-1";
      disabled = true;
    }})"}
        fi
        ;;
      open)
        hyprctl eval ${lib.escapeShellArg "hl.monitor(${toLua (laptopMonitor // {disabled = false;})})"}
        ${routerBin}
        ;;
    esac
  '';

  mod = "SUPER";
  # bind "<mods> + <key>" "<Lua dispatcher expression>" [options]
  bindWith = opts: key: dsp: {_args = [key (lua dsp)] ++ lib.optional (opts != {}) opts;};
  bind = bindWith {};
  exec = cmd: "hl.dsp.exec_cmd(${toLua cmd})";
  # Repeat while held, and keep working on the lock screen.
  repeatLocked = bindWith {
    locked = true;
    repeating = true;
  };
  locked = bindWith {locked = true;};
  repeating = bindWith {repeating = true;};
  mouse = bindWith {mouse = true;};

  workspaceKeyBinds = lib.concatMap (
    i: let
      ws = toString i;
      key = toString (lib.mod i 10);
    in [
      (bind "${mod} + ${key}" "hl.dsp.focus({ workspace = ${ws} })")
      (bind "${mod} + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${ws} })")
    ]
  ) (lib.range 1 10);

  wsRule = ws: monitor: extra: {workspace = toString ws;} // {inherit monitor;} // extra;
  workspaceRules = [
    (wsRule 1 "eDP-1" {default = true;})
    (wsRule 2 "eDP-1" {})
    (wsRule 3 "eDP-1" {})
    (wsRule 4 externalMonitorOne {default = true;})
    (wsRule 5 externalMonitorOne {})
    (wsRule 6 externalMonitorOne {})
    (wsRule 7 externalMonitorTwo {default = true;})
    (wsRule 8 externalMonitorTwo {})
    (wsRule 9 externalMonitorTwo {})
    (wsRule 10 externalMonitorTwo {})
  ];

  windowRules = [
    {
      name = "signal-float";
      match.class = "^(signal|signal-desktop|Signal)$";
      float = true;
      center = true;
      size = "monitor_w*0.7 monitor_h*0.7";
    }
  ];
in {
  home.packages = with pkgs; [
    fuzzel
    workspaceRouter
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    # Portals are configured system-wide in config/base.nix.
    portalPackage = null;
    configType = "lua";
    xwayland.enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
    };
    settings = {
      monitor = [
        laptopMonitor
        {
          output = externalMonitorOne;
          mode = "2560x1440";
          position = "2256x560";
          scale = "1";
        }
        {
          output = externalMonitorTwo;
          mode = "2560x1440";
          position = "4816x0";
          scale = "1";
          transform = 3;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "1";
        }
      ];

      on = {
        _args = [
          "hyprland.start"
          (lua ''
            function()
              hl.exec_cmd(${toLua "${startApps}"})
              hl.exec_cmd(${toLua "${monitorWatcher}"})
            end'')
        ];
      };

      env = map (args: {_args = args;}) [
        ["NIXOS_OZONE_WL" "1"]
        ["MOZ_ENABLE_WAYLAND" "1"]
        ["QT_QPA_PLATFORM" "wayland;xcb"]
      ];

      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

      config = {
        # Let XWayland apps render at native resolution instead of being
        # upscaled (blurry) at the laptop's 1.175 scale.
        xwayland.force_zero_scaling = true;

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
            tap_to_click = true;
          };
        };

        general = {
          border_size = 2;
          gaps_in = 8;
          gaps_out = 8;
          layout = "dwindle";
          resize_on_border = true;
          col = {
            active_border = "rgb(7a88cf)";
            inactive_border = "rgb(4b517a)";
          };
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
          preserve_split = true;
          smart_split = false;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          # Don't let apps (Slack, Firefox link opens) steal focus while typing.
          focus_on_activate = false;
        };

        ecosystem.no_donation_nag = true;
      };

      bind =
        [
          (bind "${mod} + Return" (exec "kitty -1 -e bash -c 'exec ~/.config/bin/ta || $SHELL'"))
          (bind "${mod} + CTRL + Return" (exec "kitty -1"))
          (bind "${mod} + CTRL + W" (exec workFirefoxCmd))
          (bind "${mod} + CTRL + H" (exec homeFirefoxCmd))
          (bind "${mod} + ALT + W" (exec "${noctalia} msg wallpaper-random"))
          (bind "${mod} + CTRL + L" (exec lockCmd))
          (bind "${mod} + Space" (exec "fuzzel"))
          (bind "${mod} + W" "hl.dsp.window.close()")
          (bind "${mod} + SHIFT + M" (exec "${noctalia} msg panel-toggle session"))
          (bind "XF86PowerOff" (exec "${noctalia} msg panel-toggle session"))
          (bind "${mod} + E" (exec "thunar"))
          (bind "${mod} + V" ''hl.dsp.window.float({ action = "toggle" })'')
          (bind "${mod} + SHIFT + V" (exec "${noctalia} msg panel-toggle clipboard"))
          (bind "${mod} + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
          (bind "${mod} + SHIFT + F" ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
          (bind "${mod} + B" (exec "oor-bw-pw"))
          (bind "${mod} + P" (exec "hyprshot -m region -z"))
          (bind "${mod} + CTRL + left" ''hl.dsp.focus({ monitor = "l" })'')
          (bind "${mod} + CTRL + right" ''hl.dsp.focus({ monitor = "r" })'')
          (bind "${mod} + CTRL + SHIFT + left" ''hl.dsp.window.move({ monitor = "l" })'')
          (bind "${mod} + CTRL + SHIFT + right" ''hl.dsp.window.move({ monitor = "r" })'')
          (bind "${mod} + H" ''hl.dsp.focus({ direction = "left" })'')
          (bind "${mod} + J" ''hl.dsp.focus({ direction = "down" })'')
          (bind "${mod} + K" ''hl.dsp.focus({ direction = "up" })'')
          (bind "${mod} + L" ''hl.dsp.focus({ direction = "right" })'')
          (bind "${mod} + SHIFT + H" ''hl.dsp.window.move({ direction = "left" })'')
          (bind "${mod} + SHIFT + J" ''hl.dsp.window.move({ direction = "down" })'')
          (bind "${mod} + SHIFT + K" ''hl.dsp.window.move({ direction = "up" })'')
          (bind "${mod} + SHIFT + L" ''hl.dsp.window.move({ direction = "right" })'')
          (bind "${mod} + SHIFT + B" (exec "bluetoothctl connect 88:C9:E8:44:61:64"))
          (bind "${mod} + SHIFT + P" (exec "hyprshot -m region -z --clipboard-only"))
          (bind "${mod} + SHIFT + R" (exec routerBin))
          (bind "${mod} + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
          (bind "${mod} + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

          (repeatLocked "XF86MonBrightnessDown" (exec "${brightnessctl} set 5%-"))
          (repeatLocked "XF86MonBrightnessUp" (exec "${brightnessctl} set 5%+"))
          (repeatLocked "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
          (repeatLocked "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))

          # Keep working on the lock screen.
          (locked "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
          (locked "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
          (locked "XF86AudioPlay" (exec "${noctalia} msg media toggle"))
          (locked "XF86AudioPause" (exec "${noctalia} msg media toggle"))
          (locked "XF86AudioNext" (exec "${noctalia} msg media next"))
          (locked "XF86AudioPrev" (exec "${noctalia} msg media previous"))
          (locked "XF86Display" (exec dpmsOffCmd))
          (locked "XF86WLAN" (exec "nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"))
          (locked "switch:on:Lid Switch" (exec "${lidSwitch} close"))
          (locked "switch:off:Lid Switch" (exec "${lidSwitch} open"))

          (repeating "${mod} + ALT + H" "hl.dsp.window.resize({ x = -40, y = 0, relative = true })")
          (repeating "${mod} + ALT + J" "hl.dsp.window.resize({ x = 0, y = 40, relative = true })")
          (repeating "${mod} + ALT + K" "hl.dsp.window.resize({ x = 0, y = -40, relative = true })")
          (repeating "${mod} + ALT + L" "hl.dsp.window.resize({ x = 40, y = 0, relative = true })")

          (mouse "${mod} + mouse:272" "hl.dsp.window.drag()")
          (mouse "${mod} + mouse:273" "hl.dsp.window.resize()")
        ]
        ++ workspaceKeyBinds;

      workspace_rule = workspaceRules;
      window_rule = windowRules;
    };
  };

  programs.hyprlock = {
    enable = true;
    extraConfig = ''
      general {
          disable_loading_bar = true
          hide_cursor = false
          grace = 0
          no_fade_in = false
      }

      background {
          monitor =
          path = ${config.xdg.configHome}/wallpapers/cliffs.jpg
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
          text = $TIME
          color = rgb(a9b1d6)
          font_size = 88
          font_family = JetBrainsMono Nerd Font
          position = 0, 140
          halign = center
          valign = center
      }

      label {
          monitor =
          text = cmd[update:60000] ${pkgs.coreutils}/bin/date +'%A, %d %B'
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
    settings = {
      general = {
        lock_cmd = lockCmd;
        before_sleep_cmd = lockCmd;
        after_sleep_cmd = dpmsOnCmd;
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
      };
      listener = [
        {
          timeout = 240;
          on-timeout = "${brightnessctl} -s set 10%";
          on-resume = "${brightnessctl} -r";
        }
        {
          timeout = 300;
          on-timeout = idleLockCmd;
        }
        {
          timeout = 330;
          on-timeout = dpmsOffCmd;
          on-resume = dpmsOnCmd;
        }
        {
          # Suspend after 20 minutes idle, but only on battery.
          timeout = 1200;
          on-timeout = "[ \"$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/ACAD/online)\" = 0 ] && ${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };
}
