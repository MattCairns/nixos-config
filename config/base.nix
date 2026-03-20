{
  pkgs,
  config,
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
          "audio.position" = [
            "FL"
            "FR"
          ];
          "capture.props" = {
            "node.name" = "effect_input.rnnoise";
            "node.passive" = true;
            "node.target" = "alsa_input.usb-Focusrite_Scarlett_2i2_USB-00.HiFi__Mic1__source";
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
  imports = [
    inputs.talon-nix.nixosModules.talon
  ];

  nixpkgs.config = {
    # Required for hardware.enableAllFirmware and Talon; predicate keeps the allowlist tight.
    allowUnfree = true;

    # Explicitly set which non-free packages can be installed
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "codeium"
        "discord"
        "google-chrome"
        "obsidian"
        "parsec-bin"
        "slack"
        "spotify"
        "teams"
        "teamviewer"
        "vagrant"
        "veracrypt"
        "vscode-extension-ms-vscode-cpptools"
        "zoom"
        "claude-code"
        "talon"
      ];

    permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings.trusted-users = [
      "root"
      "${user}"
    ];
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://mattcairns-cachix.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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

  # Bootloader.
  boot.loader = {
    timeout = 1;
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    grub.enable = false;
    grub.efiSupport = false;
    grub.device = "nodev";
  };
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedUDPPorts = [
      14559
      14557
      5000
      51820
    ];
    allowedTCPPorts = [
      4096
      14557
    ];
  };
  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  services.tailscale.enable = true;
  # programs.adb.enable = true;

  # Set your time zone and locale
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";

  programs.talon.enable = true;

  services.xserver.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;

  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = "${../assets/wallpapers/pexels-eberhard-grossgasteiger-730981.jpg}";
        fit = "Cover";
      };
      GTK = {
        application_prefer_dark_theme = lib.mkForce true;
        theme_name = lib.mkForce "Adwaita-dark";
        font_name = lib.mkForce "JetBrainsMono Nerd Font 12";
      };
    };
  };

  # Explicitly set XDG_DATA_DIRS in greetd's systemd environment so regreet
  # can discover session .desktop files. PAM DEFAULT= won't reliably propagate
  # to the greeter child process without this.
  systemd.services.greetd.environment.XDG_DATA_DIRS = "${config.services.displayManager.sessionData.desktops}/share";

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "gnome"
        "gtk"
      ];
    };
  };

  fonts.packages = with pkgs; [
    font-awesome
    # Comprehensive Nerd Fonts collection to ensure all icons are available
    nerd-fonts.iosevka
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.sauce-code-pro
    # Additional fonts that may contain missing icons
    nerd-fonts.hack
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.roboto-mono
    # Symbol and icon fonts
    noto-fonts
    noto-fonts-color-emoji
    siji
    liberation_ttf
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
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = ["NOPASSWD"];
          }
        ];
        users = ["${user}"];
      }
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

  # Prevent UPower from tracking Cantor keyboard battery via BlueZ
  services.dbus.packages = [
    pkgs.gcr
    (pkgs.writeTextDir "share/dbus-1/system.d/block-cantor-battery.conf" ''
      <!DOCTYPE busconfig PUBLIC
       "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
       "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
      <busconfig>
        <policy user="root">
          <deny send_destination="org.bluez"
                send_path="/org/bluez/hci0/dev_C8_7B_89_9F_45_98"
                send_interface="org.freedesktop.DBus.Properties"
                send_member="GetAll"/>
        </policy>
      </busconfig>
    '')
  ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  services.pulseaudio.support32Bit = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."99-input-denoising" = rnnoise_config;
  };
  users.extraGroups.audio.members = ["${user}"];

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
    NH_FLAKE = "\${HOME}/nixos-config";
  };

  # Globally available packages
  environment.systemPackages = [
    (pkgs.perl.withPackages (p: [
      p.PLS
      p.XMLSimple
    ]))
    pkgs.nixos-generators
    pkgs.docker-compose
    pkgs.brightnessctl
    pkgs.qjackctl
    pkgs.v4l-utils
    pkgs.distrobox
    pkgs.google-chrome
    pkgs.fw-ectool
    pkgs.xkeyboard_config
    pkgs.nodejs
    pkgs.libde265
    pkgs.pavucontrol
    pkgs.nh
    pkgs.git-lfs
    pkgs.parsec-bin
    pkgs.moonlight-qt
    pkgs.sccache
    pkgs.teamviewer
    # Audio tools
    pkgs.alsa-utils
    pkgs.alsa-tools
    pkgs.wireplumber
    # pkgs.vagrant
  ];

  # Audio firmware and hardware support
  hardware.firmware = [pkgs.linux-firmware];
  hardware.enableRedistributableFirmware = true;

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = ["${user}"];

  # Set up shell
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
}
