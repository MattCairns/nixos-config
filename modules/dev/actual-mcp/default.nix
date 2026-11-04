{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  codex = inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default;
  inherit (config.sops) secrets;
  # Read each secret file directly so passwords with shell metacharacters survive.
  actual-mcp = pkgs.writeShellScript "actual-mcp" ''
    export ACTUAL_SERVER_URL="$(cat ${secrets.actual-server-url.path})"
    export ACTUAL_PASSWORD="$(cat ${secrets.actual-password.path})"
    export ACTUAL_BUDGET_SYNC_ID="$(cat ${secrets.actual-budget-sync-id.path})"
    export ACTUAL_DATA_DIR="${config.xdg.cacheHome}/actual-mcp"
    mkdir -p "$ACTUAL_DATA_DIR"
    exec ${pkgs.nodejs}/bin/npx -y actual-mcp@1.15.1 --enable-write
  '';
in {
  sops.secrets = {
    actual-server-url = {};
    actual-password = {};
    actual-budget-sync-id = {};
  };

  programs.claude-code.mcpServers.actualBudget = {
    command = "${actual-mcp}";
    args = [];
  };

  # Merge into Codex's mutable config; re-add so the entry follows the store path.
  home.activation.actualMcpCodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${codex}/bin/codex mcp remove actualBudget >/dev/null 2>&1 || true
    run ${codex}/bin/codex mcp add actualBudget -- ${actual-mcp}
  '';
}
