{ config
, pkgs
, ...
}: {
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
        FirefoxHome = {
          Search = true;
          Pocket = false;
          Snippets = false;
          TopSites = false;
          Highlights = false;
        };
      };
    };
    profiles = {
      home = {
        id = 0;
        search.default = "DuckDuckGo";
        settings = {
          "browser.startup.homepage" = "duckduckgo.com";
          "privacy.clearOnShutdown.history" = true;
          "privacy.clearOnShutdown.downloads" = true;
          "privacy.clearOnShutdown.formdata" = true;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "browser.theme.content-theme" = 0;
        };
      };

      work = {
        id = 1;
        search.default = "DuckDuckGo";
        settings = {
          "browser.startup.homepage" = "ticktick.com";
          "privacy.clearOnShutdown.history" = true;
          "privacy.clearOnShutdown.downloads" = true;
          "privacy.clearOnShutdown.formdata" = true;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "browser.theme.content-theme" = 0;
        };
      };
    };
  };
}
