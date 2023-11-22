{...}: {
  users.groups.plugdev = {};
  users.users.matthew = {
    isNormalUser = true;
    description = "Matthew Cairns";
    extraGroups = ["dialout" "networkmanager" "wheel" "plugdev"];
  };
}
