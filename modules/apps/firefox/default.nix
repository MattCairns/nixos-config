{...}: let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in {
  programs = {
    firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
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
          "browser.theme.content-theme" = "dark";
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "browser.contentblocking.category" = {
            Value = "strict";
            Status = "locked";
          };
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "browser.topsites.contile.enabled" = lock-false;
          "browser.formfill.enable" = lock-false;
          "browser.search.suggest.enabled" = lock-false;
          "browser.search.suggest.enabled.private" = lock-false;
          "browser.urlbar.suggest.searches" = lock-false;
          "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
        };
        ExtensionSettings = with builtins; let
          extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "normal_installed";
            };
          };
        in
          listToAttrs [
            (extension "ublock-origin" "uBlock0@raymondhill.net")
            (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
            (extension "youtube-shorts-block" "{34daeb50-c2d2-4f14-886a-7160b24d66a4}")
            (extension "sponsorBlocker@ajay.app" "sponsorblock")
            (extension "toolkit-for-ynab" "{4F1FB113-D7D8-40AE-A5BA-9300EAEA0F51}")
            (extension "nicothin-dark-theme" "{99c277af-d778-4a0b-9faa-b1d8165f0a55}")
            (extension "nicothin-space" "{22b0eca1-8c02-4c0d-a5d7-6604ddd9836e}")
          ];
      };
      profiles = {
        home = {
          id = 0;
          name = "home";
          isDefault = true;
        };
        work = {
          id = 1;
          name = "work";
          isDefault = false;
        };
      };
    };
  };
}
