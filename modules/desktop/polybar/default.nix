{ pkgs, ... }: {
  services.polybar = {
    enable = true;
    package = pkgs.polybar;

    settings = {
      "colors" = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        accent = "#89b4fa";
        muted = "#6c7086";
        warning = "#f9e2af";
        danger = "#f38ba8";
      };

      "bar/main" = {
        monitor = "\${env:MONITOR}";
        width = "100%";
        height = "28";
        radius = 0;
        background = "\${colors.background}";
        foreground = "\${colors.foreground}";
        border-size = 0;
        padding-left = 2;
        padding-right = 2;
        module-margin = 1;
        font-0 = "FiraCode Nerd Font:size=11;2";
        font-1 = "Font Awesome 6 Free Solid:size=11";
        modules-left = "bspwm";
        modules-center = "title";
        modules-right = "pulseaudio memory cpu wlan clock";
        enable-ipc = true;
      };

      "module/bspwm" = {
        type = "internal/bspwm";
        label-focused = "%name%";
        label-focused-padding = 1;
        label-focused-foreground = "\${colors.background}";
        label-focused-background = "\${colors.accent}";
        label-occupied = "%name%";
        label-occupied-padding = 1;
        label-urgent = "!%name%!";
        label-urgent-padding = 1;
        label-urgent-background = "\${colors.danger}";
        label-empty = "%name%";
        label-empty-padding = 1;
        label-empty-foreground = "\${colors.muted}";
      };

      "module/title" = {
        type = "internal/xwindow";
        label = "%title:0:60:...%";
        label-empty = "Desktop";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        interval = 2;
        format-volume = "VOL <label-volume>";
        label-volume = "%percentage%%";
        label-muted = "MUTED";
        label-muted-foreground = "\${colors.muted}";
        click-right = "pavucontrol &";
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 5;
        label = "RAM %percentage_used%%";
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = 5;
        label = "CPU %percentage%%";
      };

      "module/wlan" = {
        type = "internal/network";
        interface-type = "wireless";
        interval = 5;
        format-connected = "<label-connected>";
        label-connected = "NET %essid% %signal%%";
        format-disconnected = "NET down";
      };

      "module/clock" = {
        type = "internal/date";
        interval = 5;
        date = "%a %b %d";
        time = "%H:%M";
        label = "%time%  %date%";
      };
    };

    script = ''
      polybar-msg cmd quit >/dev/null 2>&1 || true
      while pgrep -x polybar >/dev/null; do sleep 0.2; done

      if command -v xrandr >/dev/null 2>&1; then
        PRIMARY=$(xrandr --query | awk '/ connected primary/{print $1; exit}')
        if [ -z "$PRIMARY" ]; then
          PRIMARY=$(xrandr --query | awk '/ connected/{print $1; exit}')
        fi
      fi

      FALLBACK=$(polybar --list-monitors 2>/dev/null | head -n1 | cut -d: -f1)
      TARGET="$PRIMARY"
      if [ -z "$TARGET" ]; then
        TARGET="$MONITOR"
      fi
      if [ -z "$TARGET" ]; then
        TARGET="$FALLBACK"
      fi
      if [ -n "$TARGET" ]; then
        export MONITOR="$TARGET"
      fi
      polybar --reload main &
    '';
  };
}
