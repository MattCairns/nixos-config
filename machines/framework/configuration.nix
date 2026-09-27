{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
  ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = ["/home/matthew/.ssh/id_ed25519"];
  sops.secrets.user-matthew-password.neededForUsers = true;

  users.users.matthew.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1qMj3QQYsUCzTaEzOembl/EC9uk4s9e5wWaiRUklau ha@cairns.pro"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtxf6vcdvDoSx1IUtboLcK+EACy5H2E90apGqdHAyDe mattrcairns@gmail.com"
  ];

  #users.users.matthew.passwordFile = config.sops.secrets.user-matthew-password.path;
  users.users.matthew.hashedPasswordFile = "/persist/passwords/matthew";
  users.users.root.hashedPasswordFile = "/persist/passwords/root";

  # Kernel parameters for better AMD graphics suspend/resume
  boot.kernelParams = [
    "amdgpu.dc=1" # Enable Display Core for better display handling
    "amdgpu.gpu_recovery=1" # Enable GPU recovery on hang
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
  };

  networking.hostName = "framework";
  hardware.graphics.enable = true;
  # Bluetooth UI is provided by Noctalia.
  hardware.bluetooth.enable = true;

  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "65536";
    };
    loadModels = ["qwen3:8b"];
  };

  hardware.xpadneo.enable = true;

  # Enable touchpad support
  services.libinput.enable = true;
  # Firmware updates
  services.fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"];
  };

  fileSystems."/mnt/appdata" = {
    device = "192.168.1.10:/mnt/user/appdata";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
    ];
  };
  fileSystems."/mnt/Media" = {
    device = "192.168.1.10:/mnt/user/Media";
    fsType = "nfs";
    options = [
      "rw"
      "x-systemd.automount"
      "noauto"
    ];
  };
  fileSystems."/mnt/Photos" = {
    device = "192.168.1.10:/mnt/user/Photos";
    fsType = "nfs";
    options = [
      "rw"
      "x-systemd.automount"
      "noauto"
    ];
  };

  fileSystems."/mnt/backup" = {
    device = "192.168.1.10:/mnt/user/backup";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
    ];
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
          -i /home/matthew/.ssh/matthew_openoceanrobotics_com \
          -L 0.0.0.0:11435:localhost:11434 matthew@100.77.5.87
      '';
      User = "matthew";
      Restart = "always";
      RestartSec = 5;
    };
  };

  # Only nas may reach the forwarded Ollama port (Ollama has no auth of its own).
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp -s 192.168.1.10 --dport 11435 -j ACCEPT
  '';

  ## Power Management ##
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  networking.networkmanager.wifi.powersave = false;

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleLidSwitch = "suspend";
    # Docked: Hyprland turns the laptop panel off instead (see lid bindl).
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "suspend";
  };

  powerManagement.resumeCommands = ''
    ${pkgs.util-linux}/bin/rfkill unblock wlan
  '';

  virtualisation.libvirtd.enable = true;
  virtualisation.waydroid.enable = true;

  system.stateVersion = "22.11";
}
