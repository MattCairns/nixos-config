{ pkgs
, ...
}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
      end
      export OPENAI_API_KEY=$(cat ~/.config/secrets/openai_api_key)
    '';
    plugins = [
      { name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
      { name = "sponge"; src = pkgs.fishPlugins.sponge.src; }
    ];
    shellAliases = {
      ls = "exa";
      nd = "nix develop";
      mkenv = "echo 'use flake' >> .envrc";
      du = "dust";
      grep = "rg";
    };
  };
}
