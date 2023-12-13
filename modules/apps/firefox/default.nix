{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-beta-unwrapped {
      extraPolicies = {
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
        SanitizeOnShutdown = {
          Cache = false;
          Cookies = false;
          Downloads = true;
          FormData = true;
          History = true;
          Sessions = true;
          SiteSettings = true;
          OfflineApps = true;
          Locked = true;
        };
        SearchEngines = {
          PreventInstalls = true;
          Add = [
            {
              Name = "NixOS Search";
              Alias = "nix";
              Method = "GET";
              Description = "Search NixOS packages";
              PostData = "";
              URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
            }
            {
              Name = "Brave Search";
              Alias = "brave";
              Method = "GET";
              Description = "Search on the Brave search engine.";
              PostData = "";
              URLTemplate = "https://search.brave.com/search?q={searchTerms}";
            }
          ];
        };
        FirefoxHome = {
          Search = true;
          Pocket = false;
          Snippets = false;
          TopSites = false;
          Highlights = false;
        };
        Homepage = {
          URL = "https://search.brave.com";
          Locked = true;
        };
        Preferences = {
          browser.theme.content-theme = "dark";
          extensions.activeThemeID = "firefox-compact-dark@mozilla.org";
        };
      };
    };
    profiles = {
      home = {
        id = 0;
      };
      work = {
        id = 1;
      };
    };
  };
}
