{config, ...}: {
  programs.claude-code = {
    enable = true;
    settings = {
      model = "sonnet";
      permissions = {
        default_mode = "default";
      };
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      };
    };
    skills.pdf = ''
      ---
      name: pdf
      description: Convert PDF files to markdown for reading and extraction. Use when the user asks to read, analyze, or extract content from PDF files.
      ---

      # PDF Processing

      ## Quick start

      Use markitdown to convert a PDF to markdown:

      ```bash
      nix run nixpkgs#python313Packages.markitdown -- "path/to/file.pdf" > output.md
      ```

      Remember to quote file paths that contain spaces.
    '';
    mcpServers = {
      nixos = {
        command = "nix";
        args = ["run" "github:utensils/mcp-nixos"];
      };
      atlassian = {
        type = "http";
        url = "https://mcp.atlassian.com/v1/mcp";
      };
      gitlab = {
        command = "sh";
        args = [
          "-c"
          "GITLAB_PERSONAL_ACCESS_TOKEN=$(cat ${config.sops.secrets."gitlab-token".path}) exec npx -y @modelcontextprotocol/server-gitlab@latest"
        ];
      };
      drawio = {
        command = "npx";
        args = ["-y" "@drawio/mcp@latest"];
      };
    };
  };
}
