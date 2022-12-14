{ inputs, config, pkgs, ... }:

{
# Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

# Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = "loose";

  networking.firewall.allowedUDPPorts = [ 
    14550 
    14520 

    # Sunshine ports
    47998
    47999
    48000
    48002
    48010
  ];

  networking.firewall.allowedTCPPorts = [ 
    # Sunshine
    47984
    47989
    48010
  ];

# Set your time zone.
  time.timeZone = "America/Vancouver";

# Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

# Enable the X11 windowing system.
  services.xserver.enable = true;


# Enable the GNOME Desktop Environment.
  boot.plymouth = {
    enable = true;
    themePackages = [ inputs.mrcpkgs.legacyPackages.x86_64-linux.adi1090x-plymouth ];
    theme = "lone";
  };
  services.xserver = {
    displayManager = {
      lightdm = {
        enable = true;
        greeters.slick.enable = true;
        /* background = "/home/matthew/.config/wallpapers/camilo-contreras-b9iRx947hzY-unsplash.jpg"; */
      };
      defaultSession = "none+bspwm";
    };
    desktopManager.gnome.enable = true;
    windowManager.bspwm.enable = true;
    windowManager.bspwm.configFile = "/home/matthew/.config/bspwm/bspwmrc";
    desktopManager.xterm.enable = false;
  };
  
  fonts.fonts = with pkgs; [
    nerdfonts
    font-awesome
    siji
    (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
  ];

# Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

# Enable CUPS to print documents.
  services.printing.enable = true;

  security.polkit.enable = true;

# Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    configDir = "/home/matthew/.config/syncthing";
    user = "matthew";
    group = "users";
  };

  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  services.tailscale.enable = true;
  services.zerotierone.enable = true;

  # Set XDG environment
  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME    = "\${HOME}/.local/bin";
    XDG_DATA_HOME   = "\${HOME}/.local/share";

    PATH = [ 
      "\${XDG_BIN_HOME}"
    ];
  };

  users.defaultUserShell = pkgs.zsh;

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11"; 
}
