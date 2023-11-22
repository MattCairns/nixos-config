{pkgs, ...}: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5-new-kernel.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  hardware.enableAllFirmware = true;
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    neovim
    git
    tmux
    gparted
    nix-prefetch-scripts
    magic-wormhole
  ];

  environment.etc = {
    "00-btrfswrite" = {
      text = ''
        DISK=/dev/nvme0n1
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
        echo "If this is failing use gparted to generate a 1Gb EFI, 8Gb swap, and the rest btrfs"
        sudo nixos-generate-config --root /mnt
        #!/bin/bash

        # NixOS configuration file path
        config_file="/mnt/etc/nixos/hardware-configuration.nix"

        # Add "neededForBoot = true;" to /persist and /var/log
        sed -i '/fileSystems."\/persist" = {/,/};/ s/};/  neededForBoot = true;\n};/' "$config_file"
        sed -i '/fileSystems."\/var\/log" = {/,/};/ s/};/  neededForBoot = true;\n};/' "$config_file"

        echo "Configuration updated. Please review the changes in $config_file"
      '';

      mode = "0777";
    };
  };

  environment.etc = {
    "02-generateconfig" = {
      text = ''
        nixos-generate-config --root /mnt
        nixos-install --flake https://github.com/mattcairns/nixos-config#sun --root /mnt
        # add neededForBoot = true; to /persist and /var/log
      '';

      mode = "0777";
    };
  };

  environment.etc = {
    "01-nixos-config" = {
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
}
