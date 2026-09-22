{pkgs}:
pkgs.python3Packages.buildPythonApplication rec {
  pname = "hypruse";
  version = "0.10.0";
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-xcm2L0Z5Ixrw5rtjAXu6sg5+sPBFuvS671e/RuN8JeA=";
  };

  build-system = [pkgs.python3Packages.hatchling];
  dependencies = [pkgs.python3Packages.mcp];
  pythonImportsCheck = ["hypruse"];

  makeWrapperArgs = [
    "--prefix PATH : ${pkgs.lib.makeBinPath [pkgs.hyprland pkgs.grim pkgs.wtype pkgs.systemd pkgs.imagemagick pkgs.procps]}"
  ];

  meta = {
    description = "Hyprland desktop control over MCP";
    homepage = "https://github.com/IlyasKhallouki/hypruse";
    license = pkgs.lib.licenses.mit;
    mainProgram = "hypruse";
    platforms = pkgs.lib.platforms.linux;
  };
}
