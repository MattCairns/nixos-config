{
  pkgs,
  user,
  inputs,
  ...
}: let
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
  home.file.".talon/user/community" = {
    source = inputs.talon-community;
    recursive = true;
  };

  home.file.".talon/user/custom/demo.talon".text = ''
    tag(): user.demo

    demo hello:
        user.demo_notify("Hello from your Nix-managed Talon config!")
  '';

  home.file.".talon/user/custom/demo.py".text = ''
    from talon import Context, Module, app

    mod = Module()
    mod.tag("demo", desc="Demo commands managed by Nix")

    ctx = Context()
    ctx.matches = "tag: user.demo"

    @mod.action_class
    class Actions:
        def demo_notify(message: str):
            """Show a notification for the demo command"""
            app.notify(message)
  '';
  xdg.configFile."wallpapers".source = ../assets/wallpapers;
  xdg.configFile."bin".source = ../scripts/bin;

  sops.age.sshKeyPaths = ["/home/${user}/.ssh/id_ed25519"];
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.secrets = {
    openai-api-key = {};
    toggl-api-key = {};
    context7-token = {};
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

    sesh = {
      enable = true;
      enableTmuxIntegration = true;
      icons = true;
      tmuxKey = "C-f";
    };
  };

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    sessionPath = ["/home/${user}/.config/bin"];

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
      atuin

      # Communication
      zoom-us
      slackWithWorkBrowser
      discord
      signal-desktop

      # Video/Audio
      feh # Image Viewer
      scrot
      mpv # Media Player
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
      codex
      qwen-code
      lmstudio
      envfs

      # Formatters
      alejandra
      nixpkgs-fmt
      cmake-format

      # LSP Servers
      pyright
      cmake-language-server
      nil
      dockerfile-language-server
      nodePackages.vim-language-server
      nodePackages.vscode-json-languageserver
      lua-language-server
      buf
      codeium
      perl5Packages.PerlLanguageServer

      # Keyboards
      qmk
      dfu-util
      dfu-programmer

      blender
      bottles

      # Sharing
      tmate
      junction

      prusa-slicer

      socat
      bubblewrap

      # Custom scripts
      (import ../scripts/tmux-windowizer.nix {inherit pkgs;})
      (import ../scripts/tmux-switch-ssh-session.nix {inherit pkgs;})
      (import ../scripts/chwall.nix {inherit pkgs;})
      (import ../scripts/mosh-ssh.nix {inherit pkgs;})
      (import ../scripts/warp.nix {inherit pkgs;})
      (import ../scripts/fs-diff.nix {inherit pkgs;})
      (import ../scripts/oor-bw-pw.nix {inherit pkgs;})
      (import ../scripts/open-git.nix {inherit pkgs;})
    ];

    pointerCursor = {
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
