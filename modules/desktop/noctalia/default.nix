{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.noctalia = {
    enable = true;

    settings = {
      # Polkit authentication prompts (replaces XFCE's polkit-gnome agent).
      shell.polkit_agent = true;

      theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "tokyo-night-moon";
      };

      wallpaper = {
        directory = "/home/matthew/.config/wallpapers";
        default.path = "/home/matthew/.config/wallpapers/cliffs.jpg";
      };
    };

    # Tokyo Night Moon colorscheme
    # https://github.com/noctalia-dev/noctalia-colorschemes/blob/main/Tokyo%20Night%20Moon/Tokyo%20Night%20Moon.json
    customPalettes.tokyo-night-moon.dark = {
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
      terminal = {
        foreground = "#a9b1d6";
        background = "#1f2335";
        selectionFg = "#a9b1d6";
        selectionBg = "#4b517a";
        cursorText = "#1f2335";
        cursor = "#a9b1d6";
        normal = {
          black = "#1f2335";
          red = "#f7768e";
          green = "#9cd58a";
          yellow = "#e6c384";
          blue = "#7a88cf";
          magenta = "#d7729f";
          cyan = "#7bb0c0";
          white = "#8289a6";
        };
        bright = {
          black = "#545c7e";
          red = "#f7768e";
          green = "#9cd58a";
          yellow = "#e6c384";
          blue = "#7a88cf";
          magenta = "#d7729f";
          cyan = "#7bb0c0";
          white = "#a9b1d6";
        };
      };
    };

    # plugins = { ... };
  };

  # Dark GTK/Qt apps (Thunar, pavucontrol, file pickers) to match the shell.
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    # adw-gtk3 is GTK3-only; libadwaita apps follow color-scheme instead.
    gtk4.theme = null;
  };
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
    icon-theme = "Papirus-Dark";
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  systemd.user.services.noctalia = {
    Unit = {
      Description = "Noctalia shell";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = lib.getExe config.programs.noctalia.package;
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
