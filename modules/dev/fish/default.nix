{ config
, pkgs
, user
, ...
}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
        pfetch
      end
    '';
    plugins = [
      { name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
      { name = "sponge"; src = pkgs.fishPlugins.sponge.src; }
    ];
    shellAliases = {
      ls = "lsd";
      nd = "nix develop";
      mkenv = "echo 'use flake' >> .envrc";
    };
  };
}
