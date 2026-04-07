{
  config,
  pkgs,
  inputs,
  ...
}: {
  xdg.configFile."opencode/skills/pdf/SKILL.md".text = ''
    ---
    name: pdf
    description: Convert PDF files to markdown for reading and extraction. Use when the user asks to read, analyze, or extract content from PDF files.
    compatibility: opencode
    ---

    # PDF Processing

    ## Quick start

    Use markitdown to convert a PDF to markdown:

    ```bash
    nix run nixpkgs#python313Packages.markitdown -- "path/to/file.pdf" > output.md
    ```

    Remember to quote file paths that contain spaces.
  '';

  programs.opencode = {
    enable = true;
    package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
      };
    };
  };
}
