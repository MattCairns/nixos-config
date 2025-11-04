{
  pkgs,
  user,
  config,
  inputs,
  ...
}:
{
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

  sops.age.sshKeyPaths = [ "/home/${user}/.ssh/id_ed25519" ];
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.secrets = {
    openai-api-key = { };
    bitwarden-session-key = { };
    jira-cli-api-key = { };
    gitlab-token = { };
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
    sessionPath = [ "/home/${user}/.config/bin" ];

    packages = with pkgs; [
      home-manager

      # Terminal
      mosh
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
      dust
      jq
      atuin

      # Communication
      zoom-us
      slack
      discord

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
      flameshot
      texstudio
      qgroundcontrol
      bitwarden-cli
      gnome-solanum

      # Dev tools
      pre-commit
      lazygit
      kubectl
      cppcheck
      jira-cli-go
      glab
      perl
      codex
      claude-code
      qwen-code
      lmstudio

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
      perl540Packages.PerlLanguageServer

      # Keyboards
      qmk
      dfu-util
      dfu-programmer

      blender
      bottles

      # Sharing
      tmate
      junction

      # Custom scripts
      (import ../scripts/tmux-sessionizer.nix { inherit pkgs; })
      (import ../scripts/tmux-windowizer.nix { inherit pkgs; })
      (import ../scripts/tmux-switch-session.nix { inherit pkgs; })
      (import ../scripts/tmux-switch-ssh-session.nix { inherit pkgs; })
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
}
