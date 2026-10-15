{
  pkgs,
  config,
  lib,
  ...
}: let
  secretEnv = {
    OPENAI_API_KEY = "openai-api-key";
    GITLAB_TOKEN = "gitlab-token";
    BW_SESSION = "bitwarden-session-key";
    VAULT_PASS = "vessel-configs-vault-pass";
    MENDER_API_KEY = "mender-api-key";
    MENDER_TENANT_TOKEN = "mender-tenant-token";
    XMG_USER_STAGING = "xmg-user-staging";
    XMG_PASS_STAGING = "xmg-pass-staging";
    XMG_ENTRY_USER_STAGING = "xmg-entry-user-staging";
    XMG_ENTRY_PASS_STAGING = "xmg-entry-pass-staging";
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
