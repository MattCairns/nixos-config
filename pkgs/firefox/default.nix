{ config
, pkgs
, ...
}: {
  programs.firefox = {
    enable = true;
    profiles = {
      home = {
        id = 0;
        search.default = "DuckDuckGo";
        settings = {
          "browser.startup.homepage" = "duckduckgo.com";
          "privacy.clearOnShutdown.history" = true;
          "privacy.clearOnShutdown.downloads" = true;
          "privacy.clearOnShutdown.formdata" = true;
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
        };
      };
    };
  };
}
