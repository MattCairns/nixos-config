{
  pkgs,
  user,
  ...
}: {
  imports = [./hardware-configuration.nix];

  users.users.${user}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1qMj3QQYsUCzTaEzOembl/EC9uk4s9e5wWaiRUklau ha@cairns.pro"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtxf6vcdvDoSx1IUtboLcK+EACy5H2E90apGqdHAyDe mattrcairns@gmail.com"
  ];

  home-manager.users.${user} = {
    programs.opencode.settings = {
      model = "markv/qwen3.8:27b-mtp-64k";

      # markv (RTX 3090) via the ollama-forward-markv relay below.
      providers.markv = {
        name = "Ollama (markv)";
        package = "@opencode/ai/providers/openai-compatible";
        settings.baseURL = "http://127.0.0.1:11435/v1";
        # Ollama variant of qwen3.8:27b-mtp-q4_K_M with num_ctx 65536 baked in
        # (largest context that stays 100% on the 3090; 80K spills to CPU).
        models."qwen3.8:27b-mtp-64k" = {
          name = "Qwen 3.8 27B MTP 64K (markv)";
          capabilities.tools = true;
          limit = {
            context = 65536;
            output = 8192;
          };
        };
        models."qwen3.8:27b-abliterated-64k" = {
          name = "Qwen 3.8 27B Abliterated 64K (markv)";
          capabilities.tools = true;
          limit = {
            context = 65536;
            output = 8192;
          };
        };
      };

      providers.inkling-markv = {
        name = "Inkling 2 Mini (markv)";
        package = "@opencode/ai/providers/openai-compatible";
        settings.baseURL = "http://100.77.5.87:11437/v1";
        models."inkling-2-mini:iq4_NL" = {
          name = "Inkling 2 Mini (markv)";
          capabilities.tools = true;
          limit = {
            context = 32768;
            output = 8192;
          };
        };
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin "claude-strata" ''
        exec env \
          ANTHROPIC_BASE_URL="http://127.0.0.1:18080" \
          ANTHROPIC_AUTH_TOKEN="strata-local" \
          ANTHROPIC_MODEL="claude-sonnet-4-5" \
          ANTHROPIC_DEFAULT_OPUS_MODEL="claude-sonnet-4-5" \
          ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-4-5" \
          ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-sonnet-4-5" \
          CLAUDE_CODE_EFFORT_LEVEL="low" \
          claude "$@"
      '')
    ];

    systemd.user.services.strata-tunnel = {
      Unit = {
        Description = "SSH tunnel to Strata on the desktop";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        ExecStart = ''
          ${pkgs.openssh}/bin/ssh -N \
            -o ExitOnForwardFailure=yes \
            -o ServerAliveInterval=30 -o ServerAliveCountMax=3 \
            -o IdentitiesOnly=yes -i /home/${user}/.ssh/id_ed25519 \
            -L 127.0.0.1:18080:127.0.0.1:8080 matthew@10.42.0.232
        '';
        Restart = "always";
        RestartSec = 5;
      };
      Install.WantedBy = ["default.target"];
    };
  };

  # Kernel parameters for better AMD graphics suspend/resume
  boot.kernelParams = [
    "amdgpu.dc=1" # Enable Display Core for better display handling
    "amdgpu.gpu_recovery=1" # Enable GPU recovery on hang
  ];

  networking = {
    hostName = "framework";
    # Only nas may reach the forwarded Ollama port (Ollama has no auth of its own).
    # Match nas's MAC too: on other networks 192.168.1.10 can be anyone.
    firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp -s 192.168.1.10 -m mac --mac-source 70:85:c2:6c:b0:b0 --dport 11435 -j ACCEPT
      iptables -A nixos-fw -p tcp -s 192.168.1.10 -m mac --mac-source 70:85:c2:6c:b0:b0 --dport 11436 -j ACCEPT
      # Forward only the desktop's traffic (the dock may meet untrusted devices).
      for rule in "-s 192.168.1.30" "-d 192.168.1.30"; do
        iptables -C FORWARD $rule -j ACCEPT 2>/dev/null || iptables -I FORWARD $rule -j ACCEPT
      done
    '';
    firewall.extraStopCommands = ''
      for rule in "-s 192.168.1.30" "-d 192.168.1.30"; do
        iptables -D FORWARD $rule -j ACCEPT 2>/dev/null || true
      done
    '';
    networkmanager = {
      wifi.powersave = false;
      ensureProfiles.profiles.dock-desktop = {
        connection = {
          id = "dock-desktop";
          type = "ethernet";
          interface-name = "enp195s0f3u1u1";
        };
        ipv4 = {
          method = "manual";
          address1 = "10.42.0.1/24";
          route1 = "192.168.1.30/32";
          never-default = "true";
        };
        ipv6.method = "ignore";
      };
    };
  };

  # Put "desktop" (GPU box on the dock ethernet) on the home LAN as 192.168.1.30.
  # Wifi can't be bridged, so proxy-ARP instead: this laptop answers ARP for
  # 192.168.1.30 (and the gateway, towards the desktop) and routes between wifi and
  # the dock. The desktop is static (see machines/desktop); 10.42.0.1/24 here is
  # just a management link, so `ssh sun` (10.42.0.232) keeps working. No NAT or
  # DHCP on the dock, and not NetworkManager "shared" mode: its nft rules reject
  # forwarded traffic to/from addresses outside 10.42.0.0/24.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.proxy_arp" = 1;
  };

  hardware = {
    graphics.enable = true;
    # Bluetooth UI is provided by Noctalia.
    bluetooth.enable = true;
    xpadneo.enable = true;
  };

  services = {
    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
    };

    ollama = {
      enable = true;
      package = pkgs.ollama;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "65536";
      };
      loadModels = ["qwen3:8b"];
    };

    # Enable touchpad support
    libinput.enable = true;
    # Firmware updates
    fwupd = {
      enable = true;
      extraRemotes = ["lvfs-testing"];
    };

    ## Power Management ##
    upower.enable = true;
    power-profiles-daemon.enable = true;

    logind.settings.Login = {
      HandlePowerKey = "ignore";
      HandleLidSwitch = "suspend";
      # Docked: Hyprland turns the laptop panel off instead (see lid bindl).
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "suspend";
    };
  };

  environment.systemPackages = [
    pkgs.fw-ectool
    pkgs.brightnessctl
  ];

  fileSystems = {
    "/mnt/appdata" = {
      device = "192.168.1.10:/mnt/user/appdata";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
    "/mnt/Media" = {
      device = "192.168.1.10:/mnt/user/Media";
      fsType = "nfs";
      options = [
        "rw"
        "x-systemd.automount"
        "noauto"
      ];
    };
    "/mnt/Photos" = {
      device = "192.168.1.10:/mnt/user/Photos";
      fsType = "nfs";
      options = [
        "rw"
        "x-systemd.automount"
        "noauto"
      ];
    };

    "/mnt/backup" = {
      device = "192.168.1.10:/mnt/user/backup";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
  };

  # Relay markv's Ollama (reachable here over Tailscale) to the LAN so
  # paperless-ngx on nas (192.168.1.10) can use it as an AI backend.
  # Port 11435 (not 11434) because this laptop's own local Ollama already
  # owns 11434.
  systemd.services.ollama-forward-markv = {
    description = "Forward markv's Ollama to LAN for paperless-ngx";
    after = ["network-online.target" "tailscaled.service"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.openssh}/bin/ssh -N \
          -o ExitOnForwardFailure=yes \
          -o ServerAliveInterval=30 -o ServerAliveCountMax=3 \
          -o StrictHostKeyChecking=accept-new \
          -i /home/${user}/.ssh/matthew_openoceanrobotics_com \
          -L 0.0.0.0:11435:localhost:11434 matthew@100.77.5.87
      '';
      User = user;
      Restart = "always";
      RestartSec = 5;
    };
  };

  # Relay the desktop's Ollama (GPU box on the dock link, 10.42.0.0/24, which only
  # exists on this laptop) to the LAN so Frigate/Home Assistant on nas can use it.
  # 10.42.0.232 is the address pinned by the dnsmasq reservation above.
  # Port 11436: 11434 is this laptop's own Ollama, 11435 is the markv relay.
  systemd.sockets.ollama-forward-desktop = {
    description = "LAN socket for the desktop's Ollama";
    wantedBy = ["sockets.target"];
    listenStreams = ["0.0.0.0:11436"];
  };
  systemd.services.ollama-forward-desktop = {
    description = "Forward the desktop's Ollama to LAN for Frigate/Home Assistant";
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 10.42.0.232:11434";
      DynamicUser = true;
      PrivateTmp = true;
    };
  };

  powerManagement.resumeCommands = ''
    ${pkgs.util-linux}/bin/rfkill unblock wlan
  '';

  virtualisation.libvirtd.enable = true;
  virtualisation.waydroid.enable = true;

  system.stateVersion = "22.11";
}
