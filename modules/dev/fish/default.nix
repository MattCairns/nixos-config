{
  pkgs,
  config,
  lib,
  ...
}: let
  secretEnv = {
    JIRA_API_TOKEN = "jira-cli-api-key";
    OPENAI_API_KEY = "openai-api-key";
    GITLAB_TOKEN = "gitlab-token";
    BW_SESSION = "bitwarden-session-key";
    VAULT_PASS = "vessel-configs-vault-pass";
  };
in {
  programs = {
    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
      fileWidget.command = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
      changeDirWidget.command = "${pkgs.fd}/bin/fd --type d --hidden --follow --exclude .git";
      # Atuin owns Ctrl-R.
      historyWidget.command = "";
    };

    fish = {
      enable = true;
      generateCompletions = true;
      interactiveShellInit =
        # fish
        ''
          function fish_greeting
          end
          set -gx JIRA_AUTH_TYPE basic
          set -gx ANSIBLE_VAULT_PASSWORD_FILE ${config.sops.secrets.vessel-configs-vault-pass.path}
        ''
        + lib.concatStrings (lib.mapAttrsToList (var: secret: ''
            set -gx ${var} (cat ${config.sops.secrets.${secret}.path})
          '')
          secretEnv);
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
