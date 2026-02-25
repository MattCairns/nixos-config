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
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "suspend";
  };

  powerManagement.resumeCommands = ''
    # Unblock WiFi
    ${pkgs.util-linux}/bin/rfkill unblock wlan

    # Give displays time to initialize
    ${pkgs.coreutils}/bin/sleep 2

    # Reset monitors via hyprctl (if Hyprland is running)
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
      ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
      ${pkgs.coreutils}/bin/sleep 1
      ${pkgs.hyprland}/bin/hyprctl dispatch dpms on
    fi
  '';

  # Lock screen service disabled for BSPWM
  # (BSPWM uses xautolock/i3lock instead of hyprlock)
  systemd.services.lock-after-suspend.enable = false;

  virtualisation.libvirtd.enable = true;
  virtualisation.waydroid.enable = true;

  system.stateVersion = "22.11";
}
