{pkgs}: let
  pname = "orca-ide";
  version = "1.4.255";

  src = pkgs.fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-1ozZQ7kTV8XYyEFOfjB5G8o5og+fZAAhW7Erc9gmqiY=";
  };

  contents = pkgs.appimageTools.extract {inherit pname version src;};
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm444 ${contents}/orca-ide.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/orca-ide.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=${pname}'
      cp -r ${contents}/usr/share/icons $out/share
    '';

    meta = {
      description = "Agent development environment for running coding agents in parallel worktrees";
      homepage = "https://www.onorca.dev";
      license = pkgs.lib.licenses.mit;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
