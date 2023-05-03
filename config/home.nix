{ config
, lib
, pkgs
, test-pkgs
, mrcpkgs
, user
, inputs
, ...
}: {
  imports = [
    (import ../modules)
    inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.sops-nix.homeManagerModule
  ];
  programs.home-manager.enable = true;
  xdg.configFile."wallpapers".source = ../assets/wallpapers;
  xdg.configFile."bin".source = ../dots/bin;

  sops = {
    age.sshKeyPaths = [ "/home/${user}/.ssh/id_ed25519" ];
    defaultSopsFile = ../secrets/openai_api_key.json;
    secrets.openai-api-key = { path = "/home/${user}/.config/secrets/openai_api_key"; };
  };

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
      nvtop

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
      texstudio
      texlive.combined.scheme-full

      # Dev tools
      pre-commit
      cppcheck
      lazygit
      nixpkgs-fmt
      cmake-format
      kubectl

      # LSP Servers
      nodePackages_latest.pyright
      cmake-language-server
      nil
      rust-analyzer
      ansible-language-server

      # Keyboards
      qmk
      vial
      dfu-util
      dfu-programmer
    ];

    stateVersion = "22.11";
  };
}
