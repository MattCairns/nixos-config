{user, ...}: {
  users = {
    groups.plugdev = {};
    users.${user} = {
      isNormalUser = true;
      description = "Matthew Cairns";
      extraGroups = ["dialout" "networkmanager" "wheel" "plugdev" "qemu-libvirtd" "libvirtd"];
      hashedPasswordFile = "/persist/passwords/${user}";
    };
    users.root.hashedPasswordFile = "/persist/passwords/root";
  };
}
