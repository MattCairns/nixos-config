{
  pkgs,
  user,
  inputs,
  ...
}: {
  imports = [
    (import ../modules)
    inputs.sops-nix.homeManagerModule
  ];
  programs.home-manager.enable = true;
  xdg.configFile."wallpapers".source = ../assets/wallpapers;
  xdg.configFile."bin".source = ../dots/bin;

  sops.age.sshKeyPaths = ["/home/${user}/.ssh/id_ed25519"];
  sops.secrets = {
    openai-api-key = {
      sopsFile = ../secrets/secrets.yaml;
      path = "/home/${user}/.config/secrets/openai-api-key";
    };
    toggl-api-key = {
      sopsFile = ../secrets/secrets.yaml;
      path = "/home/${user}/.config/secrets/toggl-api-key";
    };
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    sessionPath = ["/home/${user}/.config/bin"];

    packages = with pkgs; [
      home-manager

      # Terminal
      btop
      ripgrep
      fzf
      fd
      wget
      curlWithGnuTls
      ncdu
      eza
      xclip
      magic-wormhole
      nvtop
      du-dust
      jq

      # Communication
      zoom-us
      slack
      signal-desktop

      # Video/Audio
      feh # Image Viewer
      scrot
      mpv # Media Player
      spotify

      # File Management
      ranger
      rsync
      unzip

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
      buf-language-server

      # Keyboards
      qmk
      dfu-util
      dfu-programmer
    ];

    stateVersion = "22.11";
  };
}
