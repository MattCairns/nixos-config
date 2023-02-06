{
  config,
  pkgs,
  ...
}: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matthew = {
    isNormalUser = true;
    description = "Matthew Cairns";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      # Communication
      zoom-us
      teams
      tdesktop
      slack
      signal-desktop
      discord

      # Misc
      qgroundcontrol
      obsidian
      qjackctl
      libnotify
    ];
  };
}
