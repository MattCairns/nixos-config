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
      tailscale
      syncthing
      ncdu
      kitty
      appimage-run
      starship
      zsh
      oh-my-zsh
      mpv
      vlc
      xclip
      scrot
      feh
      nitrogen
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

