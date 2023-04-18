{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5-new-kernel.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  environment.systemPackages = with pkgs; [
    wget
    neovim
    git
    tmux
    gparted
    nix-prefetch-scripts
  ];

  environment.etc = {
    nixos-config = {
      text = ''
        { config, pkgs, ... }:
        {
          imports =
            [ # Include the results of the hardware scan.
              ./hardware-configuration.nix
            ];

          boot.kernelPackages = pkgs.linuxPackages_latest;
          boot.supportedFilesystems = [ "btrfs" ];
          hardware.enableAllFirmware = true;
          nixpkgs.config.allowUnfree = true;

          # Use the systemd-boot EFI boot loader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          networking.hostName = "laptop"; # Define your hostname.
          networking.networkmanager.enable = true;

          # Enable the X11 windowing system.
          services.xserver.enable = true;

          # Enable the KDE Desktop Environment.
          services.xserver.displayManager.sddm.enable = true;
          services.xserver.desktopManager.plasma5.enable = true;

          # Define a user account. Don't forget to set a password with ‘passwd’.
          users.users.matthew = {
            isNormalUser = true;
            extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
          };

          system.stateVersion = "20.11";
        }
      '';

      mode = "0666";
    };
  };

  environment.etc = {
    btrfswrite = {
      text = ''
        sudo cryptsetup --verify-passphrase -v luksFormat "$DISK"p3
        sudo cryptsetup open "$DISK"p3 enc
        sudo mkfs.vfat -n boot "$DISK"p1
        sudo mkswap "$DISK"p2
        sudo swapon "$DISK"p2
        sudo mkfs.btrfs /dev/mapper/enc
        sudo mount -t btrfs /dev/mapper/enc /mnt
        sudo btrfs subvolume create /mnt/root
        sudo btrfs subvolume create /mnt/home
        sudo btrfs subvolume create /mnt/nix
        sudo btrfs subvolume create /mnt/persist
        sudo btrfs subvolume create /mnt/log
        sudo btrfs subvolume snapshot -r /mnt/root /mnt/root-blank
        sudo umount /mnt
        sudo mount -o subvol=root,compress=zstd,noatime /dev/mapper/enc /mnt
        sudo mkdir /mnt/home
        sudo mount -o subvol=home,compress=zstd,noatime /dev/mapper/enc /mnt/home
        sudo mkdir /mnt/nix
        sudo mount -o subvol=nix,compress=zstd,noatime /dev/mapper/enc /mnt/nix
        sudo mkdir /mnt/persist
        sudo mount -o subvol=persist,compress=zstd,noatime /dev/mapper/enc /mnt/persist
        sudo mkdir -p /mnt/var/log
        sudo mount -o subvol=log,compress=zstd,noatime /dev/mapper/enc /mnt/var/log
        sudo mkdir /mnt/boot
        sudo mount "$DISK"p1 /mnt/boot
      '';

      mode = "0666";
    };
  };
}
