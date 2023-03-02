{ inputs
, config
, pkgs
, ...
}: {
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{product}=="CubeOrange", SYMLINK="ttyPIXHAWK"
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = "loose";

  networking.firewall.enable = true;
  # networking.firewall.allowedUDPPorts = [ ];
  # networking.firewall.allowedTCPPorts = [ ];

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  boot.plymouth = {
    enable = true;
    themePackages = [ inputs.mrcoverlays.legacyPackages.x86_64-linux.adi1090x-plymouth ];
    theme = "lone";
  };

  services.xserver = {
    displayManager = {
      gdm.enable = true;
      defaultSession = "none+bspwm";
    };
    desktopManager.gnome.enable = true;
    windowManager.bspwm.enable = true;
    windowManager.bspwm.configFile = "/home/matthew/.config/bspwm/bspwmrc";
    desktopManager.xterm.enable = false;
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "SourceCodePro" "FiraCode" ]; })
    font-awesome
    siji
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  security.polkit.enable = true;

  programs.gnupg.agent.enable = true;

  services.dbus.packages = [ pkgs.gcr ];

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

  # Set XDG environment
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    PATH = [
      "\${XDG_BIN_HOME}"
    ];
  };

  users.defaultUserShell = pkgs.zsh;

}
