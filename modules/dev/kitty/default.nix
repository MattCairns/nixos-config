{...}: {
  programs.kitty = {
    enable = true;
    font.name = "FiraCode Nerd Font";

    font.size = 12;
    theme = "Tokyo Night";
    settings = {
      confirm_os_window_close = 0;
      copy_and_clear_or_interrupt = true;
      term = "tmux-256color";
    };
  };
}
