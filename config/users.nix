{ ... }: {
  users.users.matthew = {
    isNormalUser = true;
    description = "Matthew Cairns";
    extraGroups = [ "dialout" "networkmanager" "wheel" ];
  };
}
