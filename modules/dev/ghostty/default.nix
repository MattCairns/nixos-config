_: {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      font-family = "FiraCode Nerd Font Mono";
      font-size = 12;
      font-style-italic = "SemiBold"; # kitty used SemBd for italics
      theme = "TokyoNight Moon";
      window-padding-x = 4;
      window-padding-y = 4;
      confirm-close-surface = false;
      # Copy when there's a selection, otherwise send ^C (kitty's copy_and_clear_or_interrupt).
      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
        # Default ctrl+enter toggles fullscreen, which is too easy to hit by accident.
        "ctrl+enter=unbind"
      ];
    };
  };
}
