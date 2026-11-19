{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Tailscale Serve on the Unraid box (shared from its tailnet); Let's Encrypt cert.
  endpoint = "https://tower.alligator-beaver.ts.net/mcp";
  codex = inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default;
  remoteArgs = [
    "-y"
    "mcp-remote@0.16.0"
    endpoint
  ];
  desktopServer = builtins.toJSON {
    command = "${pkgs.nodejs}/bin/npx";
    args = remoteArgs;
  };
in {
  programs.claude-code.mcpServers.executor = {
    type = "http";
    url = endpoint;
  };

  programs.opencode.settings.mcp.executor = {
    type = "remote";
    url = endpoint;
  };

  home = {
    # Codex rejects this server's OAuth issuer metadata; mcp-remote signs in over stdio.
    # Codex keeps a mutable config, so merge this entry through its CLI.
    activation.executorCodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${codex}/bin/codex mcp remove executor >/dev/null 2>&1 || true
      run ${codex}/bin/codex mcp add executor -- ${pkgs.nodejs}/bin/npx ${lib.escapeShellArgs remoteArgs}
    '';

    # Keep Claude Desktop's mutable preferences when adding its MCP server.
    activation.executorClaudeDesktop = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH="${lib.makeBinPath [pkgs.coreutils pkgs.jq]}:$PATH"
      config_path="${config.xdg.configHome}/Claude/claude_desktop_config.json"
      mkdir -p "$(dirname "$config_path")"
      tmp_out=$(mktemp)

      if [ -f "$config_path" ] && jq -e . "$config_path" >/dev/null 2>&1; then
        jq --argjson server ${lib.escapeShellArg desktopServer} \
          '.mcpServers.executor = $server' "$config_path" >"$tmp_out"
      else
        jq -n --argjson server ${lib.escapeShellArg desktopServer} \
          '{mcpServers: {executor: $server}}' >"$tmp_out"
      fi

      install -m 600 "$tmp_out" "$config_path"
      rm -f "$tmp_out"
    '';
  };
}
