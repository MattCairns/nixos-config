{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.claude-code = {
    enable = true;
    skills.pdf = builtins.readFile ../skills/pdf/SKILL.md;
    mcpServers = {
      nixos = {
        command = "nix";
        args = [
          "run"
          "github:utensils/mcp-nixos"
        ];
      };
      atlassian = {
        type = "http";
        url = "https://mcp.atlassian.com/v1/mcp";
      };
      gitlab = {
        command = "sh";
        args = [
          "-c"
          "GITLAB_PERSONAL_ACCESS_TOKEN=$(cat ${
            config.sops.secrets."gitlab-token".path
          }) exec npx -y @modelcontextprotocol/server-gitlab@latest"
        ];
      };
      homeAssistant = {
        command = "sh";
        args = [
          "-c"
          "exec npx -y mcp-remote@latest \"$(cat ${config.sops.secrets."ha-mcp-url".path})\" --allow-http"
        ];
      };
      drawio = {
        command = "npx";
        args = [
          "-y"
          "@drawio/mcp@latest"
        ];
      };
      playwright = {
        command = lib.getExe pkgs.playwright-mcp;
        args = [];
      };
    };
  };

  home.activation.claudeCodeSettings = lib.hm.dag.entryAfter ["linkGeneration"] ''
    export PATH="${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.jq
      ]
    }:$PATH"

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
      "permissions": {
        "defaultMode": "plan",
        "additionalDirectories": [
          "/tmp"
        ]
      },
      "modelSettings": {
        "claude-opus-5-5": {
          "effortLevel": "medium"
        }
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
