{
  config,
  pkgs,
  user,
  lib,
  inputs,
  ...
}: {
  # Explicitly set which non-free packages can be installed
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "vscode-extension-ms-vscode-cpptools"
      "cudatoolkit"
      "zoom"
      "slack"
      "obsidian"
      "veracrypt"
      "teams"
      "google-chrome"
    ];

  # Use the latest kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback.out];
    kernelModules = ["v4l2loopback"];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1
      options v4l2loopback devices=1
      options v4l2loopback video_nr=2
      options v4l2loopback max_buffers=2
      options v4l2loopback card_label="fake-cam"
    '';
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings.trusted-users = ["root" "${user}"];
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://cuda-maintainers.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  # udev rules
  services.udev = {
    packages = [pkgs.qmk-udev-rules];
    extraRules = ''
      SUBSYSTEM=="tty", ATTRS{product}=="CubeOrange", SYMLINK="ttyPIXHAWK"
    '';
  };

  # Systemd
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=3s
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedUDPPorts = [14557];
    allowedTCPPorts = [14557];
  };
  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  services.tailscale.enable = true;

  # Set your time zone and locale
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";

  # programs.hyprland = {
  #   enable = true;
  #   package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  #   xwayland.enable = true;
  #   enableNvidiaPatches = true;
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver = {
    displayManager = {
      gdm.enable = true;
      defaultSession = "none+bspwm";
    };
    windowManager.bspwm.enable = true;
    desktopManager.gnome.enable = true;
    windowManager.bspwm.configFile = "/home/${user}/.config/bspwm/bspwmrc";
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["SourceCodePro" "FiraCode"];})
    font-awesome
    siji
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [pkgs.hplip];
  };

  programs.gnupg.agent.enable = true;
  security.polkit.enable = true;

  services.dbus.packages = [pkgs.gcr];

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

  # Enable syncthing
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    configDir = "/home/${user}/.config/syncthing";
    user = "${user}";
    group = "users";
  };

  # Set XDG environment
  environment.sessionVariables = {
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_CACHE_HOME = "\${HOME}/.local/cache";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    PATH = ["\${XDG_BIN_HOME}"];
  };

  # Globally available packages
  environment.systemPackages = [
    pkgs.nixos-generators
    pkgs.docker-compose
    pkgs.brightnessctl
    pkgs.qjackctl
    pkgs.v4l-utils
  ];

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = ["${user}"];

  # Set up shell
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
}
