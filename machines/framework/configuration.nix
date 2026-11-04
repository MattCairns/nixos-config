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
    '';
    # Dock ethernet, used to share wifi: NetworkManager "shared" mode needs DHCP/DNS in.
    # Only those ports, since the dock may also be plugged into untrusted networks.
    firewall.interfaces.enp195s0f3u1u1 = {
      allowedUDPPorts = [53 67];
      allowedTCPPorts = [53];
    };
    networkmanager.wifi.powersave = false;
  };

  # Pin "desktop" (Ollama box on the shared dock link) to one address. It runs two
  # DHCP clients on one NIC (initrd networkd for the LUKS-unlock SSH, then
  # NetworkManager) with different client IDs, so it got two leases and the initrd
  # one (previously .232) lapsed after the 1h lease time. id:* matches on MAC only.
  environment.etc."NetworkManager/dnsmasq-shared.d/desktop.conf".text = ''
    dhcp-host=4c:cc:6a:f9:47:3c,id:*,10.42.0.232,desktop
  '';

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
