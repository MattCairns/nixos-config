{ ... }: {
  users.mutableUsers = false;
  users.users.matthew = {
    isNormalUser = true;
    description = "Matthew Cairns";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
