{
  config,
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
    ../modules
  ];

  sops = {
    age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      openai-api-key = {};
      toggl-api-key = {};
      context7-token = {};
      ha-mcp-url = {};
      bitwarden-session-key = {};
      jira-cli-api-key = {};
      gitlab-token = {};
      vessel-configs-vault-pass = {};
    };
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

    atuin.enable = true;
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.local/cache";
    configFile."wallpapers".source = ../assets/wallpapers;
    configFile."bin".source = ../scripts/bin;

    desktopEntries.slack = {
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
  };

  # Also export to the systemd user manager so daemons it starts (e.g.
  # gnome-keyring) see the same paths as login shells.
  systemd.user.sessionVariables = {
    XDG_CONFIG_HOME = config.xdg.configHome;
    XDG_CACHE_HOME = config.xdg.cacheHome;
    XDG_DATA_HOME = config.xdg.dataHome;
    inherit (config.home.sessionVariables) XDG_BIN_HOME;
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    sessionPath = [
      "${config.xdg.configHome}/bin"
      "${config.home.homeDirectory}/.local/bin"
    ];
    sessionVariables.XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";

    packages = with pkgs;
      [
        # Terminal
        mosh
        btop
        ripgrep
        fd
        wget
        curlWithGnuTls
        ncdu
        eza
        wl-clipboard
        magic-wormhole
        dust
        jq
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
        qwen-code
        envfs

        # Formatters
        alejandra
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
      ]
      ++ map (script: pkgs.callPackage script {}) [
        ../scripts/tmux-sessionizer.nix
        ../scripts/tmux-windowizer.nix
        ../scripts/tmux-switch-session.nix
        ../scripts/tmux-switch-ssh-session.nix
        ../scripts/mt-copy-id.nix
        ../scripts/st.nix
        ../scripts/chwall.nix
        ../scripts/mosh-ssh.nix
        ../scripts/warp.nix
        ../scripts/fs-diff.nix
        ../scripts/oor-bw-pw.nix
        ../scripts/open-git.nix
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
}
