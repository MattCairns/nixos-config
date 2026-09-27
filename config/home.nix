{
  inputs,
  pkgs,
  user,
  ...
}: let
  codex = inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default;
  workFirefoxBrowser = pkgs.writeShellScriptBin "firefox-work" ''
    exec ${pkgs.firefox}/bin/firefox -P work --name=firefox-work "$@"
  '';
  wrappedGlab = pkgs.writeShellScriptBin "glab" ''
    exec env BROWSER="${workFirefoxBrowser}/bin/firefox-work" ${pkgs.glab}/bin/glab "$@"
  '';
  slackBrowser = pkgs.writeShellScriptBin "xdg-open" ''
    exec ${workFirefoxBrowser}/bin/firefox-work "$@"
  '';
  slackWithWorkBrowser = pkgs.writeShellScriptBin "slack" ''
    exec env PATH="${slackBrowser}/bin:$PATH" ${pkgs.slack}/bin/slack "$@"
  '';
in {
  imports = [
    (import ../modules)
  ];
  xdg.configFile."wallpapers".source = ../assets/wallpapers;
  xdg.configFile."bin".source = ../scripts/bin;
  xdg.portal.config.hyprland = {
    default = [
      "hyprland"
      "gnome"
      "gtk"
    ];
    "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
  };

  sops.age.sshKeyPaths = ["/home/${user}/.ssh/id_ed25519"];
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.secrets = {
    openai-api-key = {};
    toggl-api-key = {};
    context7-token = {};
    ha-mcp-url = {};
    bitwarden-session-key = {};
    jira-cli-api-key = {};
    gitlab-token = {};
    vessel-configs-vault-pass = {};
  };

  programs = {
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  xdg = {
    enable = true;
    cacheHome = "/home/${user}/.local/cache";
  };

  # Also export to the systemd user manager so daemons it starts (e.g.
  # gnome-keyring) see the same paths as login shells.
  systemd.user.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${user}/.config";
    XDG_CACHE_HOME = "/home/${user}/.local/cache";
    XDG_DATA_HOME = "/home/${user}/.local/share";
    XDG_BIN_HOME = "/home/${user}/.local/bin";
    NH_FLAKE = "/home/${user}/nixos-config";
  };

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    sessionPath = [
      "/home/${user}/.config/bin"
      "/home/${user}/.local/bin"
    ];
    sessionVariables = {
      XDG_BIN_HOME = "/home/${user}/.local/bin";
      NH_FLAKE = "/home/${user}/nixos-config";
    };

    packages = with pkgs; [
      home-manager

      # Terminal
      mosh
      btop
      ripgrep
      fd
      wget
      curlWithGnuTls
      ncdu
      eza
      xclip
      xsel
      wl-clipboard
      magic-wormhole
      dust
      jq
      inputs.atuin.packages.${pkgs.stdenv.hostPlatform.system}.atuin
      inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs

      # Communication
      zoom-us
      slackWithWorkBrowser
      discord
      signal-desktop

      # Video/Audio
      feh # Image Viewer
      scrot
      vlc
      spotify
      rnnoise-plugin

      # File Management
      ranger
      rsync
      unzip

      # Misc Apps
      killall
      veracrypt
      obsidian # electron insecure
      libnotify
      hyprshot
      texstudio
      qgroundcontrol
      bitwarden-cli
      gnome-solanum
      workFirefoxBrowser
      gum

      # Dev tools
      pre-commit
      lazygit
      kubectl
      cppcheck
      jira-cli-go
      wrappedGlab
      perl
      qwen-code
      envfs

      # Formatters
      alejandra
      nixpkgs-fmt
      cmake-format
      black

      # LSP Servers
      pyrefly
      cmake-language-server
      nil
      dockerfile-language-server
      lua-language-server
      buf
      codeium
      perl5Packages.PerlLanguageServer

      # Keyboards
      qmk
      dfu-util
      dfu-programmer

      blender
      codex

      # Sharing
      junction

      prusa-slicer

      socat
      bubblewrap

      # Custom scripts
      (import ../scripts/tmux-sessionizer.nix {inherit pkgs;})
      (import ../scripts/tmux-windowizer.nix {inherit pkgs;})
      (import ../scripts/tmux-switch-session.nix {inherit pkgs;})
      (import ../scripts/tmux-switch-ssh-session.nix {inherit pkgs;})
      (import ../scripts/mt-copy-id.nix {inherit pkgs;})
      (import ../scripts/st.nix {inherit pkgs;})
      (import ../scripts/chwall.nix {inherit pkgs;})
      (import ../scripts/mosh-ssh.nix {inherit pkgs;})
      (import ../scripts/warp.nix {inherit pkgs;})
      (import ../scripts/fs-diff.nix {inherit pkgs;})
      (import ../scripts/oor-bw-pw.nix {inherit pkgs;})
      (import ../scripts/open-git.nix {inherit pkgs;})
    ];

    pointerCursor = {
      enable = true;
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 32;
      gtk.enable = true;
    };

    stateVersion = "22.11";
  };

  xdg.desktopEntries.slack = {
    name = "Slack";
    comment = "Slack Desktop";
    genericName = "Slack Client for Linux";
    exec = "${slackWithWorkBrowser}/bin/slack %U";
    icon = "slack";
    type = "Application";
    startupNotify = true;
    categories = [
      "Network"
      "InstantMessaging"
    ];
    mimeType = ["x-scheme-handler/slack"];
  };
}
