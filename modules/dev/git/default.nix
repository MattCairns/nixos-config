{ config
, pkgs
, ...
}: {
  programs.git = {
    enable = true;
    userName = "Matthew Cairns";
    userEmail = "git@cairns.pro";
    extraConfig = {
      init = { defaultBranch = "main"; };
      pull = { rebase = true; };
      push = { autoSetupRemote = true; };
      core = { whitespace = "trailing-space,space-before-tab"; };
    };
  };
}
