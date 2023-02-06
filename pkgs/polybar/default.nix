{ config
, pkgs
, ...
}: {
  services.polybar = {
    enable = true;
    script =
      ''
        #!/usr/bin/env sh
        for m in $(polybar --list-monitors | cut -d":" -f1); do
            MONITOR=$m polybar --reload example 2>&1 | tee -a /tmp/polybar-$m.log & disown
        done
      '';
  };
  xdg.configFile."polybar".source = ./config;
}
