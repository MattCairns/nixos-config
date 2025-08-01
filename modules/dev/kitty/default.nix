{ ... }:
{
  programs.kitty = {
    enable = true;
    font.name = "FiraCode Nerd Font Mono";
    font.size = 12;
    extraConfig = ''
      bold_font             FiraCode Nerd Font Mono Bold
      italic_font           FiraCode Nerd Font Mono SemBd
      window_padding_width  4
    '';

    # theme = "Tokyo Night";
    themeFile = "kanagawa_lotus";
    settings = {
      confirm_os_window_close = 0;
      copy_and_clear_or_interrupt = true;
      term = "tmux-256color";
      cursor_trail = 3;
    };
  };
}
