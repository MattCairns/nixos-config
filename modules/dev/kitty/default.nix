{ config
, pkgs
, user
, ...
}: {
  programs.kitty = {
    enable = true;
    font.name = "DankMono-Regular";
    font.size = 12;
    theme = "kanagawabones";
    settings = {
      confirm_os_window_close = 0;
    };
  };
}
