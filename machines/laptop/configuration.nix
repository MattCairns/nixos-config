# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ];

# Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "laptop"; # Define your hostname.
# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# Enable networking
    networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = "loose";

# Set your time zone.
  time.timeZone = "America/Vancouver";

# Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

# Enable the X11 windowing system.
  services.xserver.enable = true;

# Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

# Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

# Enable CUPS to print documents.
  services.printing.enable = true;

# Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
# If you want to use JACK applications, uncomment this
#jack.enable = true;

# use the example session manager (no others are packaged yet so this is enabled by default,
# no need to redefine it in your config for now)
#media-session.enable = true;
  };

# Enable touchpad support (enabled default in most desktopManager).
# services.xserver.libinput.enable = true;

# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matthew = {
    isNormalUser = true;
    description = "Matthew Cairns";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      zoom-us
      teams
      qgroundcontrol
    ];
  };

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

# List packages installed in system profile. To search, run:
# $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim 
      wget
      curl
      tmux
      tailscale
      syncthing
      ncdu
      git
      appimage-run
  ];

# NeoVim setup
  environment.variables.EDITOR = "nvim";
  nixpkgs.overlays = [
    (self: super: {
     neovim = super.neovim.override {
     viAlias = true;
     vimAlias = true;
     };
     })
  ];

  services.xserver = {
    xkbOptions = "caps:swapescape";
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


# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:
  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.syncthing.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

  system.stateVersion = "22.11"; 
}
