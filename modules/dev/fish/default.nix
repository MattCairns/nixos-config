{
  pkgs,
  config,
  ...
}: {
  programs.fish = {
    enable = true;
    interactiveShellInit =
      /*
      fish
      */
      ''
        function fish_greeting
        end
        set OPENAI_API_KEY $(cat ${config.sops.secrets.openai-api-key.path})
        set BW_SESSION $(cat ${config.sops.secrets.bitwarden-session-key.path})
        export BW_SESSION=$(cat ${config.sops.secrets.bitwarden-session-key.path})
        atuin init fish | source
      '';
    plugins = [
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
    ];
    shellAliases = {
      ls = "eza";
      nd = "nix develop";
      mkenv = "echo 'use flake' >> .envrc";
      du = "dust";
      grep = "rg";
    };
  };
}
