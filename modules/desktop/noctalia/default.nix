{ ... }:
{
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;

    settings = {
      wallpaper = {
        directory = "/home/matthew/.config/wallpapers";
      };
    };
    # colors = { ... };
    # plugins = { ... };
  };
}
