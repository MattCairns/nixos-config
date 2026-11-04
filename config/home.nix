{
  config,
  inputs,
  lib,
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
  # 4.4.5 fails with -Werror under newer GCC (unused-but-set-variable).
  qgroundcontrol = pkgs.qgroundcontrol.overrideAttrs (old: {
    env = (old.env or {}) // {NIX_CFLAGS_COMPILE = "-Wno-error=unused-but-set-variable";};
  });
in {
  imports = [
    ../modules
  ];

  # Merge into Codex's mutable config; re-add so the entry follows the store path.
  home.activation.playwrightCodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${codex}/bin/codex mcp remove playwright >/dev/null 2>&1 || true
    run ${codex}/bin/codex mcp add playwright -- ${lib.getExe pkgs.playwright-mcp}
  '';

  sops = {
    age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      openai-api-key = {};
      toggl-api-key = {};
      context7-token = {};
      ha-mcp-url = {};
      ha-ntfy-topic = {};
      bitwarden-session-key = {};
      gitlab-token = {};
      vessel-configs-vault-pass = {};
      mender-api-key = {};
      mender-tenant-token = {};
      xmg-user-staging = {};
      xmg-pass-staging = {};
      xmg-entry-user-staging = {};
      xmg-entry-pass-staging = {};
      # Fine-grained: Code Download + Package Read on open-ocean-robotics (git + uv/PyPI registries).
      gitlab-netrc-token = {};
    };
    templates.netrc = {
      content = ''
        machine gitlab.com login oauth2 password ${config.sops.placeholder.gitlab-netrc-token}
      '';
      path = "${config.home.homeDirectory}/.netrc";
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
        slackWithWorkBrowser
        discord
        signal-desktop

        # Video/Audio
        vlc

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
        qgroundcontrol
        bitwarden-cli
        workFirefoxBrowser

        # Dev tools
        pre-commit
        lazygit
        wrappedGlab
        qwen-code
        antigravity-cli
        python3

        # Formatters
        alejandra
        black

        # LSP Servers
        pyrefly
        cmake-language-server
        nil
        dockerfile-language-server
        buf

        # Keyboards
        qmk
        dfu-util
        dfu-programmer

        blender
        codex

        # Sharing

        prusa-slicer

        socat
        bubblewrap
      ]
      ++ map (script: pkgs.callPackage script {}) [
        ../scripts/tmux-sessionizer.nix
        ../scripts/tmux-windowizer.nix
        ../scripts/tmux-switch-session.nix
        ../scripts/tmux-switch-ssh-session.nix
        ../scripts/tmux-ssh.nix
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
