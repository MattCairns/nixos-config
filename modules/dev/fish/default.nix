{
  pkgs,
  config,
  ...
}:
{
  programs = {
    bash.initExtra = ''
      export OPENAI_API_KEY $(cat ${config.sops.secrets.openai-api-key.path})
    '';

    fzf = {
      enable = true;
      enableFishIntegration = true;
      tmux.enableShellIntegration = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
      fileWidgetCommand = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d --hidden --follow --exclude .git";
    };

    fish = {
      enable = true;
      generateCompletions = true;
      interactiveShellInit =
        # fish
        ''
          function fish_greeting
          end
          set JIRA_API_TOKEN $(cat ${config.sops.secrets.jira-cli-api-key.path})
          set JIRA_AUTH_TYPE basic
          set OPENAI_API_KEY $(cat ${config.sops.secrets.openai-api-key.path})
          export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai-api-key.path})
          set GITLAB_TOKEN $(cat ${config.sops.secrets.gitlab-token.path})
          set BW_SESSION $(cat ${config.sops.secrets.bitwarden-session-key.path})
          export BW_SESSION=$(cat ${config.sops.secrets.bitwarden-session-key.path})
          export VAULT_PASS=$(cat ${config.sops.secrets.vessel-configs-vault-pass.path})
          export ANSIBLE_VAULT_PASSWORD_FILE=${config.sops.secrets.vessel-configs-vault-pass.path}
          atuin init fish | sed "s/-k up/up/g" | source
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
  };
}
