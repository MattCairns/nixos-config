{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../config/base.nix
    ../../config/users.nix
  ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = ["/home/matthew/.ssh/id_ed25519"];
  sops.secrets.user-matthew-password.neededForUsers = true;

  #:Wusers.users.matthew.passwordFile = config.sops.secrets.user-matthew-password.path;
  users.users.matthew.hashedPasswordFile = "/persist/passwords/matthew";
  users.users.root.hashedPasswordFile = "/persist/passwords/root";

  #boot.kernelParams = ["amdgpu.abmlevel=4"];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,";
    variant = "colemak,";
    options = "grp:shifts_toggle";
  };

  networking.hostName = "framework";
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable touchpad support
  services.xserver.libinput.enable = true;

  # Firmware updates
  services.fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"];
  };

  fileSystems."/mnt/backup" = {
    device = "192.168.1.10:/mnt/user/backup";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  ## Power Management ##
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "suspend";
  };

  powerManagement.resumeCommands = ''
    echo "This should show up in the journal after resuming."
  '';

  systemd.services.lock-after-suspend = {
    description = "Lock screen after suspending";
    wantedBy = ["post-resume.target"];
    after = ["post-resume.target"];
    script = ''
      ${pkgs.swaylock}/bin/swaylock
    '';
    serviceConfig.Type = "oneshot";
  };

  systemd.services.lock-after-suspend.enable = true;

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
  '';

  system.stateVersion = "22.11";
}
