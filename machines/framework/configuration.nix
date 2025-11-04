{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
  ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/home/matthew/.ssh/id_ed25519" ];
  sops.secrets.user-matthew-password.neededForUsers = true;

  users.users.matthew.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1qMj3QQYsUCzTaEzOembl/EC9uk4s9e5wWaiRUklau ha@cairns.pro"
  ];

  #users.users.matthew.passwordFile = config.sops.secrets.user-matthew-password.path;
  users.users.matthew.hashedPasswordFile = "/persist/passwords/matthew";
  users.users.root.hashedPasswordFile = "/persist/passwords/root";

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
    extraRemotes = [ "lvfs-testing" ];
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
    ${pkgs.util-linux}/bin/rfkill unblock wlan
  '';

  systemd.services.lock-after-suspend = {
    description = "Lock screen after suspending";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    script = ''
      ${pkgs.hyprlock}/bin/hyprlock
    '';
    serviceConfig.Type = "oneshot";
  };

  systemd.services.lock-after-suspend.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.waydroid.enable = true;

  system.stateVersion = "22.11";
}
