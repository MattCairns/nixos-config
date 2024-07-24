{
  pkgs,
  user,
  lib,
  inputs,
  ...
}: let
  rnnoise_config = {
    "context.modules" = [
      {
        "name" = "libpipewire-module-filter-chain";
        "args" = {
          "node.description" = "Noise Canceling source";
          "media.name" = "Noise Canceling source";
          "filter.graph" = {
            "nodes" = [
              {
                "type" = "ladspa";
                "name" = "rnnoise";
                "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                "label" = "noise_suppressor_stereo";
                "control" = {
                  "VAD Threshold (%)" = 85.0;
                };
              }
            ];
          };
          "audio.position" = ["FL" "FR"];
          "capture.props" = {
            "node.name" = "effect_input.rnnoise";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "effect_output.rnnoise";
            "media.class" = "Audio/Source";
          };
        };
      }
    ];
  };
in {
  # Explicitly set which non-free packages can be installed
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "vscode-extension-ms-vscode-cpptools"
      "zoom"
      "slack"
      "obsidian"
      "veracrypt"
      "teams"
      "spotify"
      "google-chrome"
      "codeium"
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_8;

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
        "https://hyprland.cachix.org"
        "https://mattcairns-cachix.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "mattcairns-cachix.cachix.org-1:bl0XYmyFCxApUSk4Eo9xAqjI7HeWBym1arunM4hLvHQ="
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
  boot.loader.timeout = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedUDPPorts = [14559 14557 5000 51820];
    allowedTCPPorts = [14557];
  };
  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  services.tailscale.enable = true;

  # Set your time zone and locale
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver.enable = true;
  services.xserver = {
    displayManager.gdm.enable = false;
    desktopManager.gnome.enable = true;
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/Hyprland";
        user = "${user}";
      };
      default_session = initial_session;
    };
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["SourceCodePro" "FiraCode"];})
    font-awesome
    siji
  ];

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [pkgs.hplip];
  };

  programs.gnupg.agent.enable = true;
  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.tailscale}/bin/tailscale";
            options = ["NOPASSWD"];
          }
        ];
        groups = ["wheel"];
      }
    ];
  };

  services.dbus.packages = [pkgs.gcr];

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."99-input-denoising" = rnnoise_config;
  };

  # Enable syncthing
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    configDir = "/home/${user}/.config/syncthing";
    dataDir = "/home/${user}/.config/syncthing";
    user = "${user}";
  };

  environment.sessionVariables = {
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_CACHE_HOME = "\${HOME}/.local/cache";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    PATH = ["\${XDG_BIN_HOME}"];
    EDITOR = "nvim";
    XCURSOR_SIZE = "32";
    FLAKE = "\${HOME}/nixos-config";
  };

  # Globally available packages
  environment.systemPackages = [
    pkgs.nixos-generators
    pkgs.docker-compose
    pkgs.brightnessctl
    pkgs.qjackctl
    pkgs.v4l-utils
    pkgs.distrobox
    pkgs.swaylock
    pkgs.google-chrome
    pkgs.fw-ectool
    pkgs.xkeyboard_config
    pkgs.nodejs
    pkgs.libde265
    pkgs.pavucontrol
    pkgs.nh
    pkgs.git-lfs
  ];

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = ["${user}"];

  # Set up shell
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
}
