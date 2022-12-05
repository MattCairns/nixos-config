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

#  services = {
#    syncthing = {
#      enable = true;
#      dataDir = "/home/matthew/Documents";
#      configDir = "/home/matthew/Documents/.config/syncthing";
#      overrideDevices = true;
#        overrideFolders = true;
#        devices = {
#          "device1" = { id = "DEVICE-ID-GOES-HERE"; };
#          "device2" = { id = "DEVICE-ID-GOES-HERE"; };
#        };
#      folders = {
#        "dev" = {        # Name of folder in Syncthing, also the folder ID
#          path = "/home/matthew/dev";    # Which folder to add to Syncthing
#            devices = [ "sun" "nuc" ];      # Which devices to share the folder with
#        };
#        #"Example" = {
#        #  path = "/home/myusername/Example";
#        #  devices = [ "device1" ];
#        #  ignorePerms = false;     # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
#        #};
#      };
#    };
#  };

  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.syncthing.enable = true;
}

