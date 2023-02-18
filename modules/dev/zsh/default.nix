{ config
, pkgs
, user
, ...
}: {
  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "lsd";
      nd = "nix develop";
    };
    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "tmux"
        "colorize"
        "cp"
        "vi-mode"
        "last-working-dir"
        "fancy-ctrl-z"
      ];
    };
  };
}
