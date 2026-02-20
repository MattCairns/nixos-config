{ ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Matthew Cairns";
        email = "git@cairns.pro";
        signingkey = "/home/matthew/.ssh/id_ed25519.pub";
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
}
