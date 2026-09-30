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
    firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp -s 192.168.1.10 --dport 11435 -j ACCEPT
    '';
    networkmanager.wifi.powersave = false;
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

  powerManagement.resumeCommands = ''
    ${pkgs.util-linux}/bin/rfkill unblock wlan
  '';

  virtualisation.libvirtd.enable = true;
  virtualisation.waydroid.enable = true;

  system.stateVersion = "22.11";
}
