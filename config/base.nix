{
  pkgs,
  user,
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
                "plugin" = "librnnoise_ladspa";
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
  nixpkgs.config.allowUnfree = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Bootloader.
    loader = {
      timeout = 1;
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = [
        "root"
        user
      ];
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

  # Enable networking
  networking = {
    networkmanager.enable = true;
    firewall = {
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
  };

  # Set your time zone and locale
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";

  programs = {
    nh = {
      enable = true;
      flake = "/home/${user}/nixos-config";
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 30d";
      };
    };

    ssh.startAgent = true;
    # adb.enable = true;

    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    hyprlock.enable = true;

    # File manager and the services XFCE used to provide for it.
    thunar.enable = true;
    xfconf.enable = true;
    dconf.enable = true;

    gnupg.agent.enable = true;

    # Set up shell
    fish.enable = true;
  };

  services = {
    # udev rules
    udev = {
      packages = [pkgs.qmk-udev-rules];
      extraRules = ''
        SUBSYSTEM=="tty", ATTRS{product}=="CubeOrange", SYMLINK="ttyPIXHAWK"
      '';
    };

    openssh.enable = true;
    tailscale.enable = true;

    xserver.enable = true;

    # File manager services (see programs.thunar).
    gvfs.enable = true;
    tumbler.enable = true;
    udisks2.enable = true;

    displayManager.sddm.enable = true;
    displayManager.defaultSession = "hyprland";

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      drivers = [pkgs.hplip];
    };

    # Unlocks the login keyring with your SDDM password (SDDM's PAM stack
    # substacks "login", so this applies there too) so apps like Slack that
    # use libsecret/Secret Service don't prompt for it after every reboot.
    gnome.gnome-keyring.enable = true;

    gnome.gcr-ssh-agent.enable = false;

    # Prevent UPower from tracking Cantor keyboard battery via BlueZ
    dbus.packages = [
      pkgs.gcr_4
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
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraLadspaPackages = [pkgs.rnnoise-plugin];
      extraConfig.pipewire."99-input-denoising" = rnnoise_config;
    };

    # Enable syncthing
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      configDir = "/home/${user}/.config/syncthing";
      dataDir = "/home/${user}/.config/syncthing";
      user = "${user}";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.common.default = "*";
    config.hyprland = {
      default = [
        "hyprland"
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
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

  security = {
    polkit.enable = true;

    sudo = {
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

    # Realtime scheduling for pipewire.
    rtkit.enable = true;
  };

  users = {
    extraGroups.audio.members = ["${user}"];
    extraGroups.docker.members = ["${user}"];

    # Set up shell
    defaultUserShell = pkgs.fish;
  };

  # HOME-relative variables (XDG_*_HOME, ~/.local/bin) live in
  # config/home.nix: pam_env expands ${HOME} before it is set, which
  # produced paths like /.local/share for early session daemons.
  environment.sessionVariables = {
    EDITOR = "nvim";
    XCURSOR_SIZE = "32";
  };

  # Globally available packages
  environment.systemPackages = [
    (pkgs.perl.withPackages (p: [
      p.PLS
      p.XMLSimple
    ]))
    pkgs.nixos-generators
    pkgs.docker-compose
    pkgs.qjackctl
    pkgs.v4l-utils
    pkgs.distrobox
    pkgs.google-chrome
    pkgs.xkeyboard_config
    pkgs.nodejs
    pkgs.libde265
    pkgs.pavucontrol
    pkgs.git-lfs
    pkgs.parsec-bin
    pkgs.moonlight-qt
    pkgs.sccache
    pkgs.teamviewer
    # Audio tools
    pkgs.alsa-utils
    pkgs.alsa-tools
    pkgs.wireplumber
    pkgs.comma
    # pkgs.vagrant
    pkgs.rustdesk
  ];

  hardware.enableRedistributableFirmware = true;

  virtualisation.docker.enable = true;
}
