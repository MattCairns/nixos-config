{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.claude-code = {
    enable = true;
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

  home.activation.claudeCodeSettings = lib.hm.dag.entryAfter ["linkGeneration"] ''
    export PATH="${lib.makeBinPath [pkgs.coreutils pkgs.jq]}:$PATH"

    claude_dir="$HOME/.claude"
    settings_path="$claude_dir/settings.json"
    tmp_base=$(mktemp)
    tmp_out=$(mktemp)

    mkdir -p "$claude_dir"

    cat >"$tmp_base" <<'EOF'
    {
      "$schema": "https://json.schemastore.org/claude-code-settings.json",
      "env": {
        "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
      },
      "model": "sonnet",
      "permissions": {
        "defaultMode": "default",
        "additionalDirectories": [
          "/tmp"
        ]
      }
    }
    EOF

    if [ -f "$settings_path" ] && jq -e . "$settings_path" >/dev/null 2>&1; then
      jq -s '.[0] * .[1]' "$settings_path" "$tmp_base" >"$tmp_out"
    else
      cp "$tmp_base" "$tmp_out"
    fi

    install -m 600 "$tmp_out" "$settings_path"
    rm -f "$tmp_base" "$tmp_out"
  '';
}
