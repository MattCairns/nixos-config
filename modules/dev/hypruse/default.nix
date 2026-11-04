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
  # Re-add every time so the entry follows the current store path.
  home.activation.hypruseCodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${codex}/bin/codex mcp remove hypruse >/dev/null 2>&1 || true
    run ${codex}/bin/codex mcp add hypruse \
      --env HYPRUSE_SCREENSHOT_MODE=image -- ${hypruse}/bin/hypruse
  '';
}
