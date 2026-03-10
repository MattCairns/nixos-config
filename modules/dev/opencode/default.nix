{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.opencode = {
    enable = true;
    package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      plugin = [
        "opencode-gemini-auth@latest"
        "opencode-worktree@latest"
        "@mohak34/opencode-notifier@latest"
      ];
      provider.google.options.projectId = "llmllm-489100";
      autoupdate = false;
      watcher.ignore = ["/nix/store/**"];
      mcp = {
        toggl = {
          type = "local";
          command = [
            "sh"
            "-c"
            "TOGGL_API_KEY=$(cat ${
              config.sops.secrets."toggl-api-key".path
            }) exec npx -y @verygoodplugins/mcp-toggl@latest"
          ];
        };
        nixos = {
          type = "local";
          command = [
            "nix"
            "run"
            "github:utensils/mcp-nixos"
          ];
        };
        atlassian = {
          type = "remote";
          url = "https://mcp.atlassian.com/v1/mcp";
        };
        context7 = {
          type = "local";
          command = [
            "sh"
            "-c"
            "CONTEXT7_API_KEY=$(cat ${
              config.sops.secrets."context7-token".path
            }) exec npx -y @upstash/context7-mcp@latest"
          ];
        };
        gitlab = {
          type = "local";
          command = [
            "sh"
            "-c"
            "GITLAB_PERSONAL_ACCESS_TOKEN=$(cat ${
              config.sops.secrets."gitlab-token".path
            }) exec npx -y @modelcontextprotocol/server-gitlab@latest"
          ];
        };
        drawio = {
          type = "local";
          command = [
            "npx"
            "-y"
            "@drawio/mcp@latest"
          ];
        };
      };
    };
  };
}
