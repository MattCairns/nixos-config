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
      };

      work = {
        id = 1;
        search.default = "DuckDuckGo";
      };
    };
  };
}
