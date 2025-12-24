{
  pkgs,
  lib,
  ...
}:
let
  polybarHotplugDaemon = pkgs.callPackage ../../../scripts/polybar-monitor-hotplug.nix { };

  mypolybar = pkgs.polybar.override {
    alsaSupport = true;
    githubSupport = true;
    mpdSupport = true;
    pulseSupport = true;
  };

  colors = {
    background = "#0d0d0d";
    foreground = "#ffffff";
    theme = "#89adfa";
  };

  bluetoothScript = pkgs.callPackage ./scripts/bluetooth.nix { };

  bctl = ''
    [module/bluetooth]
    type = custom/script
    interval = 10
    exec = ${bluetoothScript}/bin/bluetooth-ctl
    label-foreground = ${colors.foreground}
    format-foreground = ${colors.theme}
  '';

  tailscaleScript = pkgs.callPackage ./scripts/tailscale.nix { };
  tctl = ''
    [module/tailscale]
    type = custom/script
    interval = 15
    exec = ${tailscaleScript}/bin/tailscale-ctl
    label-foreground = ${colors.foreground}
    format-foreground = ${colors.theme}
  '';

  cmusctl = ''
    [module/cmus]
    type = custom/script
    tail = true
    format =♫  <label>
    interval = 5
    exec-if = "sh /etc/profiles/per-user/synchronous/bin/cmus-status 2> /dev/null | rg -v 'NO_MUSIC'"
    exec = "sh /etc/profiles/per-user/synchronous/bin/cmus-status 2> /dev/null | rg -v 'NO_MUSIC'"
    label-foreground = ${colors.foreground}
    format-foreground = ${colors.theme}
  '';

  qhd = ''
    [bar/mybar]
    height = 25
    ; Use the nerd font as the main font, with fallbacks for symbols
    font-0 = "JetBrainsMono Nerd Font:size=11;3"
    font-1 = "Noto Sans Symbols:size=11;2"
    font-2 = "Noto Color Emoji:scale=8"
    offset-x = 4
    offset-y = 3
  '';

  traymodule = ''
    [module/tray]
    type = internal/tray
    ; Only show tray on primary monitor
    tray-position = ${builtins.getEnv "TRAY_POSITION"}
    tray-detached = false
    tray-maxsize = 16
    tray-background = ${colors.background}
    tray-foreground = ${colors.foreground}
    format = <tray>
  '';

  mon = qhd;

  internets = ''
    [module/network]
    type = internal/network
    interface-type = wireless
    interval = 4.0
    udspeed-minwidth = 5
    accumulate-stats = true
    unknown-as-up = true

    format-connected = <ramp-signal> <label-connected>
    format-connected-foreground = ${colors.theme}
    label-connected = %essid% %downspeed%
    label-connected-foreground = ${colors.foreground}

    format-disconnected = 睊  <label-disconnected>
    format-disconnected-foreground = ${colors.theme}
    label-disconnected = no wifi
    label-disconnected-foreground = ${colors.foreground}

    ramp-signal-0 = 睊
    ramp-signal-1 = 直
    ramp-signal-2 = 
    ramp-signal-3 = 
    ramp-signal-4 = 
    ramp-signal-foreground = ${colors.theme}
  '';
in
{
  services.polybar = {
    enable = true;
    package = mypolybar;
    config = ./config.ini;
    extraConfig = bctl + internets + mon + traymodule + tctl + cmusctl;
    script = ''
      battery_device=""
      for path in /sys/class/power_supply/BAT*; do
        if [ -e "$path" ]; then
          battery_device=$(${pkgs.coreutils}/bin/basename "$path")
          break
        fi
      done
      [ -n "$battery_device" ] || battery_device="BAT0"

      adapter_device=""
      for path in /sys/class/power_supply/AC* /sys/class/power_supply/ADP*; do
        if [ -e "$path" ]; then
          adapter_device=$(${pkgs.coreutils}/bin/basename "$path")
          break
        fi
      done
      [ -n "$adapter_device" ] || adapter_device="AC0"

      polybar --list-monitors | while IFS=$'\n' read line; do
        monitor=$(echo $line | ${pkgs.coreutils}/bin/cut -d':' -f1)
        primary=$(echo $line | ${pkgs.coreutils}/bin/cut -d' ' -f3)
        tray_position=$([ -n "$primary" ] && echo "right" || echo "none")
        MONITOR=$monitor TRAY_POSITION=$tray_position POLYBAR_BATTERY=$battery_device POLYBAR_ADAPTER=$adapter_device polybar --reload mybar &
      done
    '';
  };

  # Restart polybar after home-manager configuration is applied with a delay to ensure bspwm is ready
  home.activation.restartPolybar = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Give the desktop environment time to fully initialize before starting polybar
    sleep 3
    ${pkgs.systemd}/bin/systemctl --user restart polybar 2>/dev/null || true
  '';

  # Custom activation to restart polybar after monitor changes
  home.activation.restartPolybarOnMonitorChange = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Function to restart polybar, can be called externally
    restart_polybar() {
      pkill polybar
      sleep 1
      # Wait for polybar to fully stop
      while pgrep -x polybar >/dev/null; do sleep 0.5; done
      # Start polybar again (it will detect all current monitors)
      ${pkgs.systemd}/bin/systemctl --user restart polybar 2>/dev/null || true
    }
    export -f restart_polybar
  '';

  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Polybar monitor hotplug detection service - DISABLED due to race condition with monitor-hotplug-daemon
  # systemd.user.services.polybar-monitor-hotplug = {
  #   Unit = {
  #     Description = "Polybar Monitor Hotplug Detection Service";
  #     After = [ "graphical-session.target" ];
  #   };

  #   Service = {
  #     Type = "simple";
  #     ExecStart = "${polybarHotplugDaemon}/bin/polybar-monitor-hotplug";
  #     Restart = "always";
  #     RestartSec = 2;
  #   };

  #   Install = {
  #     WantedBy = [ "graphical-session.target" ];
  #   };
  # };
}
