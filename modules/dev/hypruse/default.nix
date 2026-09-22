{
  lib,
  pkgs,
  ...
}: let
  hypruse = import ./package.nix {inherit pkgs;};
in {
  home.packages = [hypruse];

  # Merge this server into Codex's mutable configuration, preserving other settings.
  home.activation.hypruseCodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! ${pkgs.codex}/bin/codex mcp get hypruse >/dev/null 2>&1; then
      run ${pkgs.codex}/bin/codex mcp add hypruse \
        --env HYPRUSE_SCREENSHOT_MODE=image -- ${hypruse}/bin/hypruse
    fi
  '';
}
