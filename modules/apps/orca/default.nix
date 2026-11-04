{pkgs, ...}: {
  home.packages = [(import ./package.nix {inherit pkgs;})];
}
