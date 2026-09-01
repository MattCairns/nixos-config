{
  inputs,
  pkgs,
  user,
  ...
}:
let
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
in
{
  imports = [
    (import ../modules)
  ];
  xdg.configFile."wallpapers".source = ../assets/wallpapers;
  xdg.configFile."bin".source = ../scripts/bin;

  sops.age.sshKeyPaths = [ "/home/${user}/.ssh/id_ed25519" ];
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.secrets = {
    openai-api-key = { };
    toggl-api-key = { };
    context7-token = { };
    ha-mcp-url = { };
    bitwarden-session-key = { };
    jira-cli-api-key = { };
    gitlab-token = { };
    vessel-configs-vault-pass = { };
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

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    sessionPath = [ "/home/${user}/.config/bin" ];

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
      inputs.atuin.packages.${pkgs.system}.atuin

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

      # Sharing
      tmate
      junction

      prusa-slicer

      socat
      bubblewrap

      # Custom scripts
      (import ../scripts/tmux-sessionizer.nix { inherit pkgs; })
      (import ../scripts/tmux-windowizer.nix { inherit pkgs; })
      (import ../scripts/tmux-switch-session.nix { inherit pkgs; })
      (import ../scripts/tmux-switch-ssh-session.nix { inherit pkgs; })
      (import ../scripts/mt-copy-id.nix { inherit pkgs; })
      (import ../scripts/st.nix { inherit pkgs; })
      (import ../scripts/chwall.nix { inherit pkgs; })
      (import ../scripts/mosh-ssh.nix { inherit pkgs; })
      (import ../scripts/warp.nix { inherit pkgs; })
      (import ../scripts/fs-diff.nix { inherit pkgs; })
      (import ../scripts/oor-bw-pw.nix { inherit pkgs; })
      (import ../scripts/open-git.nix { inherit pkgs; })
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
    mimeType = [ "x-scheme-handler/slack" ];
  };
}
