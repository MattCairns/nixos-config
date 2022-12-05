{ config, lib, pkgs, user, ... }:

{ 
  imports = [ 
    ../pkgs/neovim.nix
    ../pkgs/bspwm.nix
    ];

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
      /* kitty */
      starship

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


      xclip
      scrot
      feh
      nitrogen
      autorandr
    ];
    stateVersion = "22.11";
  };


  programs = {
    home-manager.enable = true;
    kitty = {
      enable = true;
      font.name = "DankMono";
      font.size = 12;
      theme = "kanagawabones";
    };
    /* hyprland.enable = true; */
    zsh.enable = true;
    zsh.oh-my-zsh = {
      enable = true;
      plugins = ["git" "tmux"];
    };
  };

}
