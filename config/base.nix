{ config, pkgs, ... }:
{
# Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

# Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = "loose";

# Set your time zone.
  time.timeZone = "America/Vancouver";

# Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

# Enable the X11 windowing system.
  services.xserver.enable = true;

# Enable the GNOME Desktop Environment.
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    windowManager.bspwm.enable = true;
    displayManager.defaultSession = "none+bspwm";
    windowManager.bspwm.configFile = "/home/matthew/.config/bspwm/bspwmrc";
    windowManager.bspwm.sxhkd.configFile= "/home/matthew/.config/sxhkd/sxhkdrc";
    desktopManager.xterm.enable = false;
  };

# Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

# Enable CUPS to print documents.
  services.printing.enable = true;

# Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.xserver = {
    xkbOptions = "caps:swapescape";
  };

  system.stateVersion = "22.11"; 
}
