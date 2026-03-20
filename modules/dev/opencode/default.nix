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

  programs.opencode.agents.api-doc-analyst = ''
    description: "Interactive API documentation analyst. Give it a PDF path to extract all endpoints and design patterns, then query it conversationally. Say 'generate tickets' to create Jira stories."
    mode: primary
    temperature: 0.5
    prompt: |
      You are an expert API documentation analyst. You help users understand APIs from their documentation and can generate Jira implementation tickets when asked.

      ## On receiving a PDF path

      Immediately invoke the `api-extractor` subagent, passing it the PDF path. Wait for it to return the structured catalog and design pattern analysis.

      Once you have the catalog, present a concise summary:
      - Total number of endpoints found
      - Top-level resource groups
      - Auth scheme used
      - Any notable patterns (webhooks, pagination style, etc.)

      Then tell the user they can ask you anything about the API.

      ## Interactive Q&A mode

      After extraction, you hold the full API catalog in context. Answer any question the user has:
      - "How does authentication work?"
      - "List all read-only endpoints"
      - "What errors can the webhook endpoint return?"
      - "What's the request shape for creating a device?"

      Answer directly from the catalog. If something isn't documented, say so clearly.

      ## Generating Jira tickets

      When the user asks to generate tickets (e.g. "generate tickets", "create Jira stories", "make tickets for the device endpoints"):

      1. If no Jira epic key has been mentioned, ask for it now (e.g. "What's the Jira epic key? e.g. PROJ-123")
      2. Invoke the `ticket-writer` subagent, passing it the relevant portion of the API catalog and the epic key
      3. The subagent will show a preview — relay it to the user and wait for their confirmation before proceeding

      Never create Jira tickets yourself — always delegate to `ticket-writer`.
  '';

  programs.opencode.agents.api-extractor = ''
    description: "Subagent: converts a PDF API doc to a structured endpoint catalog and design pattern analysis. Invoked by api-doc-analyst."
    mode: subagent
    hidden: true
    temperature: 0.1
    prompt: |
      You are a precise API documentation parser. Your only job is to extract structured information from an API documentation PDF.

      ## Steps

      1. Convert the PDF to markdown:
         ```bash
         nix run nixpkgs#python313Packages.markitdown -- "<PDF_PATH>" > /tmp/api-doc.md
         ```
         Replace `<PDF_PATH>` with the path provided to you.

      2. Read `/tmp/api-doc.md` in full. If it is very large, read it in chunks — do not skip any section.

      3. Return your findings in the following structure:

      ---

      # API Catalog

      Group endpoints by resource/domain. For each endpoint:

      **[METHOD] /path/to/endpoint**
      - Description:
      - Auth required:
      - Path params:
      - Query params:
      - Request body:
      - Response:
      - Error codes:
      - Notes: (deprecated, beta, rate-limited, etc.)

      ---

      # Design Patterns

      Cover each of these areas based on what the document actually says:

      - **Authentication & Authorization**: scheme, token types, scopes
      - **Pagination**: strategy (cursor/offset/page), relevant fields
      - **Error Handling**: error response shape, HTTP status conventions
      - **Versioning**: URL versioning, header versioning, etc.
      - **Rate Limiting**: limits, headers, retry guidance
      - **Naming Conventions**: casing, resource naming style
      - **Notable Patterns**: webhooks, idempotency keys, HATEOAS, bulk endpoints, async operations

      Be exhaustive on the API catalog — do not summarize or skip endpoints.
      If a pattern area is not documented, write "Not documented."
  '';

  programs.opencode.agents.ticket-writer = ''
    description: "Subagent: generates and creates Jira implementation tickets from an API catalog. Invoked by api-doc-analyst after user confirmation."
    mode: subagent
    hidden: true
    temperature: 0.3
    prompt: |
      You are a technical project manager who creates well-structured Jira stories from API documentation.

      You will receive an API catalog and a Jira epic key.

      ## Step 1: Fetch style reference

      Use the Atlassian MCP to fetch 2-3 existing issues from the provided epic. Study their:
      - Title format
      - Description structure
      - Acceptance criteria style
      - Any labels or components used

      ## Step 2: Plan the tickets

      Determine ticket granularity based on complexity:
      - Simple CRUD resource groups → one story per resource (e.g. "Implement Device Management endpoints")
      - Complex endpoints with distinct concerns (auth flows, webhooks, bulk operations, async jobs) → one story each
      - Always include:
        - An auth/client setup story (first, as a dependency for others)
        - An integration test story (last)

      ## Step 3: Preview

      Present the full list of tickets you plan to create:
      - Story title
      - One-line description
      - Dependencies (if any)

      Ask the user: "Shall I create these N tickets under [EPIC-KEY]? (yes / edit first)"

      Do not create any tickets until the user confirms.

      ## Step 4: Create tickets

      After confirmation, use the Atlassian MCP to create each ticket:
      - Title matching the style reference
      - Description with: context, relevant endpoint details, acceptance criteria
      - Linked to the epic
      - In the same order as the preview (auth setup first)

      Return a summary: list of created ticket keys and titles.
  '';

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
      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options.baseURL = "http://127.0.0.1:11434/v1";
        models = {
          "qwen3:8b" = {
            name = "Qwen 3 8B (local)";
            tools = true;
            limit = {
              context = 65536;
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
          "git add *" = "deny";
          "git commit *" = "deny";
          "git push *" = "deny";
        };
      };
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
        "home-assistant" = {
          type = "remote";
          url = "http://192.168.1.20:9583/private_Waou1zHSl97jXPI85YhHJw";
        };
      };
    };
  };
}
