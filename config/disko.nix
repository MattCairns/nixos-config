# Reusable disko module for a single-disk GPT layout:
#   EFI (vfat) + swap + LUKS -> btrfs subvolumes
#
# Subvolumes created:
#   /root      -> /           (ephemeral, rolled back on boot by optin-persistence.nix)
#   /root-blank -> snapshot of /root at install time (created by postCreateHook)
#   /home      -> /home
#   /nix       -> /nix
#   /persist   -> /persist    (neededForBoot)
#   /log       -> /var/log    (neededForBoot)
#
# Usage (in a machine configuration.nix):
#   imports = [
#     (import ../../config/disko.nix {
#       inherit lib;
#       disk = "/dev/disk/by-id/nvme-your-drive";
#       swapSize = "32G";
#     })
#   ];
{
  lib,
  disk,
  swapSize ? "8G",
  efiSize ? "1G",
  luksName ? "enc",
  btrfsMountOptions ? [
    "compress=zstd"
    "noatime"
  ],
  enableHibernate ? true,
}: {
  assertions = [
    {
      assertion = disk != null && disk != "";
      message = "disko: set disk = \"/dev/disk/by-id/...\"; in the host configuration.";
    }
  ];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = disk;
      content = {
        type = "gpt";
        partitions =
          {
            ESP = {
              size = efiSize;
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
          }
          // lib.optionalAttrs (swapSize != null) {
            swap = {
              size = swapSize;
              content =
                {type = "swap";}
                // lib.optionalAttrs enableHibernate {resumeDevice = true;};
            };
          }
          // {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = luksName;
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = btrfsMountOptions;
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = btrfsMountOptions;
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = btrfsMountOptions;
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = btrfsMountOptions;
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = btrfsMountOptions;
                    };
                  };
                  # Create the read-only root-blank snapshot used by optin-persistence.nix
                  # to roll back / to a blank state on every boot.
                  # The guard makes this idempotent if disko is re-run.
                  postCreateHook = ''
                    MNTPOINT=$(mktemp -d)
                    mount "/dev/mapper/${luksName}" "$MNTPOINT" -o subvol=/
                    trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
                    if ! btrfs subvolume show "$MNTPOINT/root-blank" > /dev/null 2>&1; then
                      btrfs subvolume snapshot -r "$MNTPOINT/root" "$MNTPOINT/root-blank"
                    fi
                  '';
                };
              };
            };
          };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
