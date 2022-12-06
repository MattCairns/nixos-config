{ config, lib, pkgs, user, ... }:

{ 
  imports =  
    [(import ../pkgs/neovim.nix)] ++
    [(import ../pkgs/bspwm.nix)];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";

    packages = with pkgs; [
      # Terminal
      htop              
      pfetch            
      ranger            
      ripgrep
      fzf
      fd
      wget
      curl
      tmux
      ncdu

      # Video/Audio
      feh               # Image Viewer
      mpv               # Media Player
      pavucontrol       # Audio Control
      vlc               # Media Player

      # Apps
      appimage-run      # Runs AppImages on NixOS
      firefox           # Browser

      # File Management
      rsync             # Syncer - $ ssync -r dir1/ dir2/
      unzip             # Zip Files
      unrar             # Rar Files


      killall
      xfontsel
      xclip
      scrot
      feh
      nitrogen
      autorandr
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

  services.picom = {
    enable = true;
    menuOpacity = 0.8;
    inactiveOpacity = 0.99;
    fade = true;
    fadeDelta = 6;
    fadeSteps = [ 0.03 0.03 ];
    backend = "xrender";
    vSync = true;
  };

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
    zsh.enable = true;
    zsh.enableAutosuggestions = true;
    zsh.oh-my-zsh = {
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
}
