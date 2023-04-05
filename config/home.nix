{ config
, lib
, pkgs
, mrcpkgs
, user
, ...
}: {
  imports = [ (import ../modules/dev/neovim) ]
    ++ [ (import ../modules/dev/git) ]
    ++ [ (import ../modules/dev/kitty) ]
    ++ [ (import ../modules/dev/alacritty) ]
    ++ [ (import ../modules/dev/starship) ]
    ++ [ (import ../modules/dev/tmux) ]
    ++ [ (import ../modules/dev/zsh) ]
    ++ [ (import ../modules/desktop/bspwm) ]
    ++ [ (import ../modules/desktop/sxhkd) ]
    ++ [ (import ../modules/desktop/polybar) ]
    ++ [ (import ../modules/desktop/rofi) ]
    ++ [ (import ../modules/desktop/picom) ]
    ++ [ (import ../modules/desktop/dunst) ]
    ++ [ (import ../modules/desktop/betterlockscreen) ]
    ++ [ (import ../modules/apps/firefox) ];

  programs.home-manager.enable = true;
  xdg.configFile."wallpapers".source = ../assets/wallpapers;
  xdg.configFile."bin".source = ../dots/bin;

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    sessionPath = [ "/home/${user}/.config/bin" ];

    packages = with pkgs; [
      home-manager

      # Terminal 
      htop
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
      neofetch
      xclip
      scrot
      feh

      # Communication
      zoom-us
      tdesktop
      slack
      signal-desktop
      discord

      # Video/Audio
      feh # Image Viewer
      mpv # Media Player
      vlc # Media Player

      # File Management
      ranger
      rsync
      unzip # Zip Files
      unrar # Rar Files

      # Misc Apps
      killall
      appimage-run # Runs AppImages on NixOS
      veracrypt
      cura
      openscad
      qgroundcontrol
      obsidian
      qjackctl
      libnotify
      flameshot

    ];
    stateVersion = "22.11";
  };
}
