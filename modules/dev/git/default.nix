_: {
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
          name = "Matthew Cairns";
          email = "git@cairns.pro";
          signingkey = "/home/matthew/.ssh/matthew_openoceanrobotics_com.pub";
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
          name = "Matthew Cairns";
          email = "git@cairns.pro";
        };
        signing = {
          behavior = "drop";
          backend = "ssh";
          key = "/home/matthew/.ssh/matthew_openoceanrobotics_com.pub";
        };
        git.sign-on-push = true;
        ui.editor = "vim";
      };
    };
  };
}
