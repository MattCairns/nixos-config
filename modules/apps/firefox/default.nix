{ config
, pkgs
, ...
}: {
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-esr-102-unwrapped {
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
          URL = "https://duckduckgo.com";
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
