{
  config,
  lib,
  pkgs,
  mrcpkgs,
  user,
  ...
}: {
  imports =
    [ (import ../modules/dev/neovim) ]
    ++ [ (import ../modules/dev/git) ]
    ++ [ (import ../modules/desktop/bspwm) ]
    ++ [ (import ../modules/desktop/sxhkd) ]
    ++ [ (import ../modules/desktop/polybar) ]
    ++ [ (import ../modules/desktop/rofi) ]
    ++ [ (import ../modules/desktop/picom) ]
    ++ [ (import ../modules/desktop/dunst) ]
    ++ [ (import ../modules/desktop/betterlockscreen) ]
    ++ [ (import ../modules/tools/tmux) ]
    ++ [ (import ../modules/apps/firefox) ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    sessionPath = ["/home/${user}/.config/bin"];

    packages = with pkgs; [
      home-manager
      # Terminal
      htop
      pfetch
      ranger
      ripgrep
      fzf
      fd
      wget
      curl
      ncdu
      tree
      hexyl
      zoxide
      bat
      lsd
      btop
      neofetch

      # Video/Audio
      feh # Image Viewer
      mpv # Media Player
      pavucontrol # Audio Control
      vlc # Media Player

      # Apps
      appimage-run # Runs AppImages on NixOS
      veracrypt

      # File Management
      rsync # Syncer - $ ssync -r dir1/ dir2/
      unzip # Zip Files
      unrar # Rar Files

      killall
      xclip
      scrot
      feh
      nitrogen
    ];
    stateVersion = "22.11";
  };


  xdg.configFile."wallpapers".source = ../assets/wallpapers;
  xdg.configFile."bin".source = ../dots/bin;

  ## Terminal Configs
  programs = {
    home-manager.enable = true;
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    kitty = {
      enable = true;
      font.name = "DankMono-Regular";
      font.size = 12;
      theme = "kanagawabones";
    };
    zsh = {
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
  };
}
