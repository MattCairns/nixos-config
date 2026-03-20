{
  pkgs,
  inputs,
  ...
}: let
  nanocoderPatched =
    inputs.nanocoder.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
    (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          mkdir -p "$out/lib/nanocoder/source/config"
          cp ${inputs.nanocoder}/source/config/themes.json "$out/lib/nanocoder/source/config/themes.json"
        '';
    });
in {
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
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "65536";
    };
    loadModels = ["qwen3:8b"];
  };

  environment.systemPackages = [
    nanocoderPatched
  ];

  home-manager.users.matthew.xdg.configFile."nanocoder/agents.config.json".text = ''
    {
      "nanocoder": {
        "providers": [
          {
            "name": "ollama",
            "baseUrl": "http://192.168.1.232:11434/v1",
            "models": [
              "qwen2.5-coder:7b-instruct",
              "qwen3.5:9b",
              "qwen3:8b"
            ],
            "requestTimeout": -1,
            "socketTimeout": -1
          }
        ]
      }
    }
  '';

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

  fileSystems."/mnt/backup" = {
    device = "192.168.1.10:/mnt/user/backup";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
    ];
  };

  ## Power Management ##
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "suspend";
  };

  powerManagement.resumeCommands = ''
    ${pkgs.util-linux}/bin/rfkill unblock wlan
  '';

  systemd.services.lock-after-suspend.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.waydroid.enable = true;

  system.stateVersion = "22.11";
}
