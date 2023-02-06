{ config
, lib
, pkgs
, user
, ...
}: {
  imports =
    [ (import ../pkgs/neovim) ]
    ++ [ (import ../pkgs/bspwm) ]
    ++ [ (import ../pkgs/sxhkd) ]
    ++ [ (import ../pkgs/polybar) ]
    ++ [ (import ../pkgs/tmux) ]
    ++ [ (import ../pkgs/firefox) ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";

    packages = with pkgs; [
      home-manager
      # Terminal
      htop
      pfetch
      ranger
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
      btop
      neofetch

      # Video/Audio
      feh # Image Viewer
      mpv # Media Player
      pavucontrol # Audio Control
      vlc # Media Player

      # Apps
      appimage-run # Runs AppImages on NixOS
      veracrypt

      # File Management
      rsync # Syncer - $ ssync -r dir1/ dir2/
      unzip # Zip Files
      unrar # Rar Files

      killall
      xclip
      scrot
      feh
      nitrogen
    ];
    stateVersion = "22.11";
  };

  ## WM Configs
  programs = {
    rofi = {
      enable = true;
      theme = "gruvbox-dark-hard";
    };
  };

  services = {
    picom = {
      enable = true;
      menuOpacity = 0.8;
      fade = true;
      fadeDelta = 6;
      fadeSteps = [ 0.03 0.03 ];
      backend = "xrender";
      vSync = true;
    };
    betterlockscreen = {
      enable = true;
      arguments = [ "blur" ];
    };
    dunst = {
      enable = true;
      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "30x50";
          origin = "top-right";
          transparency = 5;
          frame_color = "#eceff1";
          corner_radius = 10;
        };
        urgency_normal = {
          background = "#181818";
          foreground = "#dfdfdf";
          timeout = 10;
        };
      };
    };
  };

  xdg.configFile."wallpapers".source = ../dots/wallpapers;
  xdg.configFile."bin".source = ../dots/bin;

  ## Terminal Configs
  programs = {
    home-manager.enable = true;
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    kitty = {
      enable = true;
      font.name = "DankMono-Regular";
      font.size = 12;
      theme = "kanagawabones";
    };
    zsh = {
      enable = true;
      shellAliases = {
        ls = "lsd";
        nd = "nix develop";
      };
      enableAutosuggestions = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "tmux"
          "colorize"
          "cp"
          "vi-mode"
          "last-working-dir"
          "fancy-ctrl-z"
        ];
      };
    };
  };
}
