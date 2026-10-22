{
  config,
  pkgs,
  ...
}: let
  sources = import ../skills/sources.nix {inherit pkgs;};
in {
  xdg.configFile = {
    "opencode/skills/pdf/SKILL.md".source = ../skills/pdf/SKILL.md;

    "opencode/skills/domain-modeling".source = "${sources.mattPocock}/skills/engineering/domain-modeling";
    "opencode/skills/grill-with-docs".source = "${sources.mattPocock}/skills/engineering/grill-with-docs";
    "opencode/skills/grilling".source = "${sources.mattPocock}/skills/productivity/grilling";
    "opencode/skills/typesafe-ai".source = "${sources.typesafeAi}/skills/typesafe-ai";

    "opencode/command/grill-with-docs.md".text = ''
      ---
      description: Grill a design and write docs as terms and decisions resolve.
      ---

      Use the `grill-with-docs` skill on $ARGUMENTS.
    '';
  };

  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    settings = {
      plugin = [
        "opencode-gemini-auth@latest"
        "opencode-anthropic-oauth@latest"
      ];
      provider.google.options.projectId = "llmllm-489100";
      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (desktop)";
        options.baseURL = "http://192.168.1.232:11434/v1";
        models = {
          "qwen2.5-coder:7b-instruct" = {
            name = "Qwen 2.5 Coder 7B Instruct (desktop)";
            tools = true;
            limit = {
              context = 16384;
              output = 8192;
            };
          };
          "qwen2.5:7b-instruct-q4_K_M" = {
            name = "Qwen 2.5 7B Instruct Q4_K_M (desktop)";
            tools = true;
            limit = {
              context = 16384;
              output = 8192;
            };
          };
          "qwen3:8b" = {
            name = "Qwen 3 8B (desktop)";
            tools = true;
            limit = {
              context = 16384;
              output = 8192;
            };
          };
        };
      };
      autoupdate = false;
      permission = {
        "*" = "allow";
        bash = {
          "*" = "allow";
          "git push *" = "deny";
        };
      };
      watcher.ignore = ["/nix/store/**"];
      mcp = {
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
        homeAssistant = {
          type = "remote";
          url = "{file:${config.sops.secrets."ha-mcp-url".path}}";
          oauth = false;
        };
      };
    };
  };
}
