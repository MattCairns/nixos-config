{ config
, pkgs
, ...
}: {
  users.mutableUsers = false;

  users.users.matthew = {
    isNormalUser = true;
    description = "Matthew Cairns";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    passwordFile = "/persist/passwords/matthew";
  };

  users.users.root.passwordFile = "/persist/passwords/root";
}
