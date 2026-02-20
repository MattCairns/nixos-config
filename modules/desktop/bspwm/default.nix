{
  pkgs,
  machine,
  ...
}:
let
  lib = pkgs.lib;

  # Import monitor-hotplug scripts
  monitorHotplug = pkgs.callPackage ../../../scripts/monitor-hotplug.nix { };
  monitorHotplugDaemon = pkgs.callPackage ../../../scripts/monitor-hotplug-daemon.nix { inherit monitorHotplug; };

  wallpaperPath = "/home/matthew/.config/wallpapers/pexels-eberhard-grossgasteiger-730981.jpg";

  defaultWorkspaceMap = {
    FIREFOX_WORK = "7";
    FIREFOX_HOME = "7";
    SLACK = "9";
    KITTY = "4";
    OBSIDIAN = "";
    SPOTIFY = "10";
  };

  perMachineWorkspace = {
    framework = defaultWorkspaceMap // {
      OBSIDIAN = "5";
    };
    laptop = defaultWorkspaceMap // {
      OBSIDIAN = "5";
    };
    nuc = {
      FIREFOX_WORK = "4";
      FIREFOX_HOME = "4";
      SLACK = "6";
      KITTY = "3";
      OBSIDIAN = "";
      SPOTIFY = "9";
    };
  };

  machineWorkspaceOverrides = lib.attrByPath [ machine ] { } perMachineWorkspace;

  workspaceMap = defaultWorkspaceMap // machineWorkspaceOverrides;

  workspaceExports = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "export ${name}=\"${value}\"") workspaceMap
  );

  monitorSetup =
    if machine == "framework" then
      ''
        xrandr --output eDP-1 \
               --mode 2256x1504 \
               --pos 0x1224 \
               --rotate normal \
               --output DP-1 --off \
               --output DP-2 --off \
               --output DP-3 --off \
               --output DP-4 --off \
               --output DP-5 --off \
               --output DP-6 --off \
               --output DP-7 --off \
               --output DP-8 --off \
               --output DP-9 --off \
               --output DP-10 --off \
               --output DP-11 --primary --mode 2560x1440 --pos 2256x560 --rotate normal \
               --output DP-12 --off \
               --output DP-13 --mode 2560x1440 --pos 4816x0 --rotate right

        monitors=$(bspc query -M --names)
        internal_monitor="eDP-1"

        if echo "$monitors" | grep -qx "$internal_monitor"; then
          bspc monitor "$internal_monitor" -d 1 2 3
        fi

        externals=$(printf '%s\n' $monitors | grep -v "^$internal_monitor$")
        set -- $externals
        if [ $# -ge 1 ]; then
          bspc monitor "$1" -d 4 5 6
        fi
        if [ $# -ge 2 ]; then
          bspc monitor "$2" -d 7 8 9
        fi
        if [ $# -ge 3 ]; then
          bspc monitor "$3" -d 10
        fi
      ''
    else if machine == "laptop" then
      ''
        # Use mons for automatic monitor detection and configuration
        if command -v mons >/dev/null 2>&1; then
          # Run mons to detect and configure monitors, then configure bspwm accordingly
          monitors=$(bspc query -M --names)
          internal_monitor="eDP-1"
          
          # Check if only internal monitor is present
          if [ $(echo "$monitors" | wc -l) -eq 1 ] && echo "$monitors" | grep -qx "$internal_monitor"; then
            bspc monitor "$internal_monitor" -d 1 2 3 4 5
          else
            # Multiple monitors detected, assign desktops appropriately
            if echo "$monitors" | grep -qx "$internal_monitor"; then
              bspc monitor "$internal_monitor" -d 1 2 3
            fi
            
            externals=$(printf '%s\n' $monitors | grep -v "^$internal_monitor$")
            set -- $externals
            if [ $# -ge 1 ]; then
              bspc monitor "$1" -d 4 5 6 7 8 9 10
            fi
          fi
        else
          # Fallback to original logic if mons is not available
          monitors=$(bspc query -M --names)
          internal_monitor="eDP-1"

          if echo "$monitors" | grep -qx "$internal_monitor"; then
            bspc monitor "$internal_monitor" -d 1 2 3 4 5
          fi

          externals=$(printf '%s\n' $monitors | grep -v "^$internal_monitor$")
          set -- $externals
          if [ $# -ge 1 ]; then
            bspc monitor "$1" -d 6 7 8 9 10
          fi
        fi
      ''
    else
      ''
        monitors=$(bspc query -M --names)
        if [ -z "$monitors" ]; then
          exit 0
        fi

        for m in $monitors; do
          bspc monitor "$m" -d 1 2 3 4 5 6 7 8 9 10
        done
      '';

  spotifyBindings =
    let
      value = workspaceMap.SPOTIFY;
    in
    if value != "" then
      ''
        super + s
            bspc desktop -f ^${value}

        super + shift + s
            bspc node -d ^${value}
      ''
    else
      ''
        super + s
            bspc desktop -f next.local
      '';
in
{
  home.packages = with pkgs; [
    bspwm
    sxhkd
    rofi
    xdotool
    xrandr
    xset
    i3lock
    mons
  ];

  xsession.enable = true;
  xsession.windowManager.bspwm = {
    enable = true;
    package = pkgs.bspwm;

    settings = {
      border_width = 2;
      window_gap = 8;
      split_ratio = 0.52;
      pointer_follows_focus = true;
      focus_follows_pointer = true;
      borderless_monocle = true;
      gapless_monocle = true;
      remove_disabled_monitors = true;
      remove_unplugged_monitors = true;
      click_to_focus = "any";
      active_border_color = "#33ccff";
      focused_border_color = "#33ccff";
      normal_border_color = "#595959";
      presel_feedback_color = "#33ccff";
      top_padding = 25; # Reserve space for polybar at the top
    };

    extraConfigEarly = ''
      ${workspaceExports}

      pkill -x sxhkd 2>/dev/null || true
      sxhkd &

      ${monitorSetup}
    '';

    extraConfig = ''
      setsid -f ~/.config/bspwm/set-wallpaper.sh
      setsid -f ~/.config/bspwm/start-apps.sh
    '';
  };

  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
    fade = true;
    fadeDelta = 5;
    settings = {
      shadow = true;
      shadow-radius = 15;
      shadow-offset-x = -15;
      shadow-offset-y = -15;
      shadow-opacity = 0.25;
      blur-background = false;
    };
  };

  xdg.configFile."sxhkd/sxhkdrc" = {
    text = ''
      super + Return
          kitty -c ~/.config/kitty/kitty.conf -e bash -c 'exec ~/.config/bin/ta || $SHELL'

      super + ctrl + Return
          kitty

      super + shift + w
          firefox -p work

      super + shift + h
          firefox -P home

      super + alt + w
          ~/.config/bin/chwall ~/.config/wallpapers

      super + shift + l
          i3lock -c 000000

      super + ctrl + b
          systemctl --user restart picom.service

      super + space
          rofi -show drun -display-drun "" -show-icons

      super + w
          bspc node -c

      super + m
          bspc quit

      super + e
          dolphin

      super + v
          bspc node -t floating

      super + r
          rofi -show run

      super + b
          oor-bw-pw

      super + p
          bspc node -t pseudo_tiled

      super + ctrl + Left
          bspc desktop -m prev

      super + ctrl + Right
          bspc desktop -m next

      super + {h,j,k,l}
          bspc node -f {west,south,north,east}

      super + shift + {h,j,k,l}
          bspc node -s {west,south,north,east}

      super + {1,2,3,4,5,6,7,8,9,0}
          bspc desktop -f ^{1,2,3,4,5,6,7,8,9,10}

      super + shift + {1,2,3,4,5,6,7,8,9,0}
          bspc node -d ^{1,2,3,4,5,6,7,8,9,10}

      super + button4
          bspc desktop -f next.local

      super + button5
          bspc desktop -f prev.local

      ${spotifyBindings}

      XF86MonBrightnessDown
          brightnessctl set 5%-

      XF86MonBrightnessUp
          brightnessctl set 5%+

      XF86AudioMute
          wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

      XF86AudioMicMute
          wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      XF86AudioRaiseVolume
          wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+

      XF86AudioLowerVolume
          wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

      XF86WLAN
          nmcli radio wifi | grep -q "enabled" && nmcli radio wifi off || nmcli radio wifi on

      XF86Display
          xset dpms force off

      super + shift + b
          bluetoothctl connect 88:C9:E8:44:61:64

      super + shift + d
          ~/.local/bin/monitor-hotplug
    '';
  };

  xdg.configFile."bspwm/start-apps.sh" = {
    source = ./config/start-apps.sh;
    executable = true;
  };

  xdg.configFile."bspwm/set-wallpaper.sh" = {
    source = ./config/set-wallpaper.sh;
    executable = true;
  };

  # Enable the monitor hotplug detection service
  systemd.user.services.mons-hotplug = {
    Unit = {
      Description = "Automatic monitor hotplug detection with mons";
      After = [ "graphical-session.target" ];
      PartOf = "graphical-session.target";
    };

    Service = {
      Type = "simple";
      Environment = [
        "DISPLAY=:0"
        "XAUTHORITY=%h/.Xauthority"
      ];
      ExecStart = "${monitorHotplugDaemon}/bin/monitor-hotplug-daemon";
      Restart = "always";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
