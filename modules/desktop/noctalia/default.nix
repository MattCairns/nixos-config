{ ... }:
{
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;

    settings = {
      wallpaper = {
        directory = "/home/matthew/.config/wallpapers";
      };
    };

    # Tokyo Night Moon colorscheme
    # https://github.com/noctalia-dev/noctalia-colorschemes/blob/main/Tokyo%20Night%20Moon/Tokyo%20Night%20Moon.json
    colors = {
      mPrimary = "#7a88cf";
      mOnPrimary = "#1f2335";
      mSecondary = "#d7729f";
      mOnSecondary = "#1f2335";
      mTertiary = "#9cd58a";
      mOnTertiary = "#1f2335";
      mError = "#f7768e";
      mOnError = "#1f2335";
      mSurface = "#1f2335";
      mOnSurface = "#a9b1d6";
      mSurfaceVariant = "#2c314a";
      mOnSurfaceVariant = "#c0caf5";
      mOutline = "#4b517a";
      mShadow = "#181b2a";
      mHover = "#9cd58a";
      mOnHover = "#1f2335";
    };

    # plugins = { ... };
  };
}
