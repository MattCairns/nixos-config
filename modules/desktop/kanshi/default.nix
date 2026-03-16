{pkgs, ...}: let
  externalMonitorOne = "desc:ASUSTek COMPUTER INC PA278CV LCLMQS261918";
  externalMonitorTwo = "desc:ASUSTek COMPUTER INC PA278QV LBLMQS297570";

  workspaceRouter = pkgs.callPackage ../../../scripts/hypr-workspace-router.nix {
    inherit externalMonitorOne externalMonitorTwo;
  };

  routerBin = "${workspaceRouter}/bin/hypr-workspace-router";
in {
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile = {
          name = "undocked";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "2256x1504";
              scale = 1.25;
              position = "0,1224";
              status = "enable";
            }
          ];
          exec = ["${routerBin} undocked"];
        };
      }
      {
        profile = {
          name = "docked";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "2256x1504";
              scale = 1.25;
              position = "0,1224";
              status = "enable";
            }
            {
              criteria = "ASUSTek COMPUTER INC PA278CV LCLMQS261918";
              mode = "2560x1440";
              position = "2256,560";
              status = "enable";
            }
            {
              criteria = "ASUSTek COMPUTER INC PA278QV LBLMQS297570";
              mode = "2560x1440";
              transform = "270";
              position = "4816,0";
              status = "enable";
            }
          ];
          exec = ["${routerBin} docked"];
        };
      }
      {
        profile = {
          name = "fallback";
          outputs = [
            {
              criteria = "eDP-1";
              scale = 1.25;
              status = "enable";
            }
            {
              criteria = "*";
              status = "enable";
            }
          ];
          exec = ["${routerBin} fallback"];
        };
      }
    ];
  };
}
