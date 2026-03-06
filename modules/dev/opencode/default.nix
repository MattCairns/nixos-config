{ config, ... }:
{
  programs.opencode = {
    enable = true;
    settings = {
      plugin = [
        "opencode-gemini-auth@latest"
        "opencode-worktree@latest"
      ];
      provider.google.options.projectId = "llmllm-489100";
      autoupdate = false;
      watcher.ignore = [ "/nix/store/**" ];
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
      };
    };
  };
}
