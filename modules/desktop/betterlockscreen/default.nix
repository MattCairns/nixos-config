{ pkgs, user, ... }:
{
  services.betterlockscreen = {
    enable = true;
    arguments = [ "blur" ];
  };

  systemd.user.services.betterlockscreen-set-bg = {
    Unit.Description = "Automatically cache a desktop image for betterlockscreen";
    Unit.After = [ "graphical.target" ];
    Install.WantedBy = [ "default.target" ];
    Service = {
      ExecStartPre = "/run/current-system/sw/bin/sleep 60";
      Environment = "DISPLAY=:0";
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.betterlockscreen}/bin/betterlockscreen --span --update /home/${user}/.config/wallpapers/lukasz-szmigiel-8AdYB7M4OHY-unsplash.jpg";
    };
  };
}
