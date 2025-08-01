{ ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Matthew Cairns";
    userEmail = "git@cairns.pro";
    extraConfig = {
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
      user = {
        signingkey = "/home/matthew/.ssh/id_ed25519.pub";
      };
      core = {
        whitespace = "trailing-space,space-before-tab";
        editor = "vim";
      };
    };
  };
}
