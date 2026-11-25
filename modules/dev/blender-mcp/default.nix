{
  inputs,
  lib,
  pkgs,
  ...
}: let
  codex = inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # MCP for Blender (github.com/ahujasid/mcp-for-blender): an MCP server that talks to
  # a socket server (localhost:9876) run by a Blender addon. Keep both on one release.
  serverVersion = "2.3.1";
  addonRev = "a5a8acf2c6ae44a73670e0caf34663f16456d645"; # main at the 2.3.1 release

  addonScripts = pkgs.runCommand "blender-mcp-addon" {} ''
    install -Dm444 ${pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/ahujasid/mcp-for-blender/${addonRev}/addon.py";
      hash = "sha256-s2PltHZexTiVySvJjzQzUkIGWhZNlbZz8fhDMirE4Ds=";
    }} $out/addons/blender_mcp.py
  '';

  # BLENDER_SYSTEM_SCRIPTS adds a script path next to the bundled one, and --addons
  # enables the addon for the session, so nothing in ~/.config/blender is touched.
  # The addon's self-update can't write to the store, so turn its check off.
  blender = pkgs.symlinkJoin {
    name = "blender-with-mcp-${pkgs.blender.version}";
    paths = [pkgs.blender];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/blender \
        --set BLENDER_SYSTEM_SCRIPTS ${addonScripts} \
        --set BLENDERMCP_NO_UPDATE_CHECK 1 \
        --add-flags "--addons blender_mcp"
    '';
  };

  # uvx would fetch a python-build-standalone interpreter, which can't run on NixOS.
  server = pkgs.writeShellScript "blender-mcp" ''
    export UV_PYTHON_DOWNLOADS=never
    exec ${pkgs.uv}/bin/uvx --python ${pkgs.python3}/bin/python3 mcp-for-blender==${serverVersion} "$@"
  '';
in {
  home.packages = [blender];

  programs.claude-code.mcpServers.blender = {
    command = "${server}";
    args = [];
  };

  programs.opencode.settings.mcp.blender = {
    type = "local";
    command = ["${server}"];
  };

  # Merge into Codex's mutable config; re-add so the entry follows the store path.
  home.activation.blenderMcpCodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${codex}/bin/codex mcp remove blender >/dev/null 2>&1 || true
    run ${codex}/bin/codex mcp add blender -- ${server}
  '';
}
