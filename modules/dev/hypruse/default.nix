{
  inputs,
  lib,
  pkgs,
  ...
}: let
  codex = inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default;
  hypruse = import ./package.nix {inherit pkgs;};
in {
  home.packages = [hypruse];

  # Merge this server into Codex's mutable configuration, preserving other settings.
  home.activation.hypruseCodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! ${codex}/bin/codex mcp get hypruse >/dev/null 2>&1; then
      run ${codex}/bin/codex mcp add hypruse \
        --env HYPRUSE_SCREENSHOT_MODE=image -- ${hypruse}/bin/hypruse
    fi
  '';
}
