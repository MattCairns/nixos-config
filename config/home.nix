{ pkgs
, user
, inputs
, ...
}: {
  imports = [
    (import ../modules)
    inputs.sops-nix.homeManagerModule
  ];
  programs.home-manager.enable = true;
  xdg.configFile."wallpapers".source = ../assets/wallpapers;
  xdg.configFile."bin".source = ../dots/bin;

  sops.age.sshKeyPaths = [ "/home/${user}/.ssh/id_ed25519" ];
  sops.secrets.openai-api-key = {
    sopsFile = ../secrets/openai_api_key.json;
    path = "/home/${user}/.config/secrets/openai_api_key";
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
      bat
      lsd
      neofetch
      xclip
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
      scrot
      mpv # Media Player

      # File Management
      gnome.nautilus
      ranger
      rsync
      unzip
      unrar

      # Misc Apps
      killall
      veracrypt
      cura
      obsidian
      libnotify
      flameshot
      bitwarden
      texstudio
      texlive.combined.scheme-full

      # Dev tools
      pre-commit
      lazygit
      nixpkgs-fmt
      cmake-format
      kubectl
      cppcheck

      # LSP Servers
      nodePackages_latest.pyright
      cmake-language-server
      nil
      rust-analyzer
      ansible-language-server
      nodePackages_latest.dockerfile-language-server-nodejs
      nodePackages.vim-language-server
      lua-language-server

      # Keyboards
      qmk
      dfu-util
      dfu-programmer
    ];

    stateVersion = "22.11";
  };
}
