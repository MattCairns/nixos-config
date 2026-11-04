{
  config,
  lib,
  pkgs,
  ...
}: let
  sources = import ../skills/sources.nix {inherit pkgs;};
in {
  xdg.configFile =
    {
      "opencode/skills/pdf/SKILL.md".source = ../skills/pdf/SKILL.md;

      "opencode/command/grill-with-docs.md".text = ''
        ---
        description: Grill a design and write docs as terms and decisions resolve.
        ---

        Use the `grill-with-docs` skill on $ARGUMENTS.
      '';
    }
    // lib.mapAttrs' (name: dir: lib.nameValuePair "opencode/skills/${name}" {source = dir;}) sources.sharedSkills;

  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    settings = {
      model = "ollama/qwen3-vl:4b-instruct";
      agents.build.steps = 12;
      plugin = [
        # Pinned: these run with your credentials, so upgrade deliberately.
        "opencode-gemini-auth@2.0.1"
        "opencode-anthropic-oauth@0.4.7"
      ];
      provider.google.options.projectId = "llmllm-489100";
      providers.ollama = {
        name = "Ollama (desktop)";
        settings.baseURL = "http://127.0.0.1:11436/v1";
        models = {
          "qwen3-vl:4b-instruct" = {
            name = "Qwen 3 VL 4B Instruct (desktop)";
            capabilities.tools = true;
            limit = {
              context = 32768;
              output = 8192;
            };
          };
          "lfm2.5:8b" = {
            name = "LFM 2.5 8B (desktop)";
            capabilities.tools = true;
            limit = {
              context = 16384;
              output = 8192;
            };
          };
          "qwen2.5-coder:7b-instruct" = {
            name = "Qwen 2.5 Coder 7B Instruct (desktop)";
            capabilities.tools = true;
            limit = {
              context = 32768;
              output = 8192;
            };
          };
          "qwen2.5:7b-instruct-q4_K_M" = {
            name = "Qwen 2.5 7B Instruct Q4_K_M (desktop)";
            capabilities.tools = true;
            limit = {
              context = 16384;
              output = 8192;
            };
          };
          "qwen3:8b" = {
            name = "Qwen 3 8B (desktop)";
            capabilities.tools = true;
            body.think = false;
            limit = {
              context = 32768;
              output = 8192;
            };
          };
          "qwen3.5:9b" = {
            name = "Qwen 3.5 9B (desktop, non-thinking)";
            capabilities.tools = true;
            body.think = false;
            limit = {
              context = 32768;
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
            }) exec npx -y @upstash/context7-mcp@4.5.0"
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
