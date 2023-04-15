{ config
, lib
, pkgs
, mrcpkgs
, user
, ...
}: {
  imports = [ (import ../modules) ];
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
      magic-wormhole
      pfetch

      # Communication
      zoom-us
      slack
      discord
      signal-desktop

      # Video/Audio
      feh # Image Viewer
      mpv # Media Player
      spotify-tui

      # File Management
      ranger
      rsync
      unzip # Zip Files
      unrar # Rar Files

      # Misc Apps
      killall
      veracrypt
      cura
      openscad
      obsidian
      libnotify
      flameshot
      bitwarden

      # Dev tools
      pre-commit
      cppcheck
      lazygit
      nixpkgs-fmt
      cmake-format

      # LSP Servers
      nodePackages_latest.pyright
      cmake-language-server
      rnix-lsp

      # Keyboards
      qmk
      vial
      dfu-util
      dfu-programmer
    ];

    stateVersion = "22.11";
  };
}
