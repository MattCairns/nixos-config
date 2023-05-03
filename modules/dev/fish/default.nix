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
      export OPENAI_API_KEY=$(cat ~/.config/secrets/openai_api_key)
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
