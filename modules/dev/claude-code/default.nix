{
  config,
  lib,
  pkgs,
  ...
}: let
  sources = import ../skills/sources.nix {inherit pkgs;};
in {
  programs.claude-code = {
    enable = true;
    skills =
      {
        pdf = builtins.readFile ../skills/pdf/SKILL.md;
      }
      // sources.sharedSkills;
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
          "GITLAB_TOKEN=$(cat ${
            config.sops.secrets.gitlab-token.path
          }) exec ${lib.getExe pkgs.glab} mcp serve"
        ];
      };
      homeAssistant = {
        command = "sh";
        args = [
          "-c"
          "exec npx -y mcp-remote@0.16.0 \"$(cat ${config.sops.secrets."ha-mcp-url".path})\" --allow-http"
        ];
      };
      drawio = {
        command = "npx";
        args = [
          "-y"
          "@drawio/mcp@1.10.1"
        ];
      };
      playwright = {
        command = lib.getExe pkgs.playwright-mcp;
        args = [];
      };
    };
  };

  # Space is a hold-tap layer key on the keyboard, so push-to-talk can't hold it.
  home.file.".claude/keybindings.json".text = builtins.toJSON {
    "$schema" = "https://www.schemastore.org/claude-code-keybindings.json";
    "$docs" = "https://code.claude.com/docs/en/keybindings";
    bindings = [
      {
        context = "Chat";
        bindings = {
          space = null;
          "meta+v" = "voice:pushToTalk";
        };
      }
    ];
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
        "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
        "DISABLE_TELEMETRY": "1",
        "DISABLE_ERROR_REPORTING": "1"
      },
      "attribution": {
        "commit": "",
        "pr": ""
      },
      "permissions": {
        "defaultMode": "plan",
        "blockReadsOutsideWorkingDirectories": false,
        "additionalDirectories": [
          "/tmp"
        ]
      },
      "modelSettings": {
        "claude-opus-5-5": {
          "effortLevel": "medium"
        }
      },
      "extraKnownMarketplaces": {
        "unifi-plugins": {
          "source": {
            "source": "github",
            "repo": "sirkirby/unifi-mcp",
            "ref": "network/v0.44.0"
          }
        }
      },
      "enabledPlugins": {
        "unifi-network@unifi-plugins": true
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
