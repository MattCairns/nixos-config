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
        set JIRA_API_TOKEN $(cat ${config.sops.secrets.jira-cli-api-key.path})
        set JIRA_AUTH_TYPE basic 
        set OPENAI_API_KEY $(cat ${config.sops.secrets.openai-api-key.path})
        set GITLAB_TOKEN $(cat ${config.sops.secrets.gitlab-token.path})
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
