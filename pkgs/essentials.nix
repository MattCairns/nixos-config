{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim 
      wget
      curl
      fzf
      ripgrep
      fd
      tmux
      ncdu
      kitty
      appimage-run
      starship
      oh-my-zsh
      mpv
      vlc
      xclip
      scrot
      feh
      nitrogen
      autorandr
      ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = ["git" "tmux"];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    configDir = "/home/matthew/.config/syncthing";
    user = "matthew";
    group = "users";
  };

  services.openssh.enable = true;
  services.tailscale.enable = true;
}

