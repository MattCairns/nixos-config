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
    btrfswrite = {
      text = ''
        #!/usr/bin/env bash
        cryptsetup --verify-passphrase -v luksFormat "$DISK"p3
        cryptsetup open "$DISK"p3 enc
        mkfs.vfat -n boot "$DISK"p1
        mkswap "$DISK"p2
        swapon "$DISK"p2
        mkfs.btrfs /dev/mapper/enc
        mount -t btrfs /dev/mapper/enc /mnt

        btrfs subvolume create /mnt/root
        btrfs subvolume create /mnt/home
        btrfs subvolume create /mnt/nix
        btrfs subvolume create /mnt/persist
        btrfs subvolume create /mnt/log

        btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

        umount /mnt
        mount -o subvol=root,compress=zstd,noatime /dev/mapper/enc /mnt

        mkdir /mnt/home
        mount -o subvol=home,compress=zstd,noatime /dev/mapper/enc /mnt/home

        mkdir /mnt/nix
        mount -o subvol=nix,compress=zstd,noatime /dev/mapper/enc /mnt/nix

        mkdir /mnt/persist
        mount -o subvol=persist,compress=zstd,noatime /dev/mapper/enc /mnt/persist

        mkdir -p /mnt/var/log
        mount -o subvol=log,compress=zstd,noatime /dev/mapper/enc /mnt/var/log

        mkdir /mnt/boot
        mount "$DISK"p1 /mnt/boot

      '';

      mode = "0440";
    };
  };
}
