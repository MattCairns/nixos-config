{config, ...}: let
  name = "Matthew Cairns";
  email = "git@cairns.pro";
  signingKey = "${config.home.homeDirectory}/.ssh/matthew_openoceanrobotics_com.pub";
in {
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      ignores = [
        "AGENTS.md"
        "CLAUDE.md"
      ];
      settings = {
        user = {
          inherit name email;
          signingkey = signingKey;
        };
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = true;
        };
        fetch = {
          prune = true;
        };
        rebase = {
          autostash = true;
          autosquash = true;
        };
        push = {
          autoSetupRemote = true;
        };
        commit = {
          gpgsign = true;
        };
        rerere = {
          enabled = true;
        };
        gpg = {
          format = "ssh";
        };
        core = {
          whitespace = "trailing-space,space-before-tab";
          editor = "vim";
        };
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          inherit name email;
        };
        signing = {
          behavior = "drop";
          backend = "ssh";
          key = signingKey;
        };
        git.sign-on-push = true;
        ui.editor = "vim";
      };
    };
  };
}
