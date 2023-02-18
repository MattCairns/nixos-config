{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "Matthew Cairns";
    userEmail = "git@cairns.pro";
  };
}
