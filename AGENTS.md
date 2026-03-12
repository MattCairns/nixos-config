# AGENTS.md

Agent guide for working in this NixOS flake repository.
Optimized for coding agents that need predictable commands and conventions.

## Scope
- Repository type: NixOS + Home Manager config managed with flakes.
- Primary language: Nix (with some embedded shell snippets).
- Main entrypoint: `flake.nix`.
- Active host currently in `machines/default.nix`: `framework`.

## Rule Files
- Cursor rules: not found (`.cursor/rules/` and `.cursorrules` absent).
- Copilot instructions: not found (`.github/copilot-instructions.md` absent).
- Additional local context exists in `CLAUDE.md` and `QWEN.md`.
- If Cursor/Copilot rules are added later, treat them as high-priority supplements.

## Repository Layout
- `flake.nix`: flake inputs, outputs, formatter, and checks.
- `machines/default.nix`: host definitions and system assembly.
- `machines/<host>/configuration.nix`: host-specific NixOS settings.
- `config/base.nix`: shared NixOS settings.
- `config/home.nix`: shared Home Manager settings.
- `modules/`: modular Home Manager config (`dev/`, `desktop/`, `apps/`).
- `scripts/*.nix`: helper scripts packaged into the user environment.

## Setup and Discovery
- Enter repo: `cd ~/nixos-config`
- Show flake outputs: `nix flake show`
- Check Nix version: `nix --version`
- List available check names:
  `nix eval .#checks.x86_64-linux --apply builtins.attrNames`

## Build Commands
- Build all checks: `nix flake check --show-trace`
- Build framework system derivation (CI-equivalent):
  `nix build .#nixosConfigurations.framework.config.system.build.toplevel --print-build-logs`
- Build via rebuild flow without switching:
  `nixos-rebuild build --flake .#framework`

## Lint Commands
- Format check (CI): `nix run nixpkgs#alejandra -- --check .`
- Dead code scan (CI): `nix run nixpkgs#deadnix -- .`
- Static lint (CI): `nix run nixpkgs#statix -- check .`

### Single-file linting
- Format-check one file:
  `nix run nixpkgs#alejandra -- --check path/to/file.nix`
- Deadnix one file:
  `nix run nixpkgs#deadnix -- path/to/file.nix`
- Statix one file:
  `nix run nixpkgs#statix -- check path/to/file.nix`

## Format Commands
- Format entire repo: `alejandra .`
- Format one file: `alejandra path/to/file.nix`
- Prefer formatting before lint/check commands.

## Test Commands
In this repo, tests are primarily flake checks and targeted check derivations.
- Run all tests/checks: `nix flake check --show-trace`

### Run a single test/check (important)
- Build one check by name:
  `nix build .#checks.x86_64-linux.<check-name>`
- Current checks from `flake.nix`:
  - `only-framework-exists`
  - `framework-amd-params`
  - `framework-hostname`
- Examples:
  - `nix build .#checks.x86_64-linux.only-framework-exists`
  - `nix build .#checks.x86_64-linux.framework-amd-params`
  - `nix build .#checks.x86_64-linux.framework-hostname`

## System Apply Commands
- `nixos-rebuild` can be run without `sudo` in this environment.
- Test activation (not default):
  `nixos-rebuild test --flake .#framework`
- Switch/apply configuration:
  `nixos-rebuild switch --flake .#framework`
- Use `test` before `switch` for boot/kernel/display/network/auth changes.

## Coding Style: Nix
- Use `alejandra` formatting as source of truth.
- Keep files declarative and expression-oriented.
- Prefer small composable modules over large monoliths.
- Keep top-level args explicit (`{ pkgs, lib, config, ... }` as needed).
- Remove unused arguments; do not keep stale params.
- Prefer `inherit`/`inherit (x)` to avoid repetition.
- Use `let ... in` for values reused more than once.
- Keep attribute sets stable and grouped by concern.
- Use trailing semicolons and standard multiline list style.

## Imports and Composition
- Put `imports` near the top of each module.
- Use relative local paths (`./`, `../`) consistently.
- Keep module filenames as `default.nix` unless a strong reason exists.
- When adding a module, wire it through the relevant aggregator:
  `modules/default.nix`, host config, or both.

## Naming Conventions
- Attribute names: lowerCamelCase (`allowUnfreePredicate`, `extraSpecialArgs`).
- File/directory names: kebab-case where appropriate (`open-git.nix`).
- Check names: short kebab-case invariants (`framework-hostname`).
- Script package names should match installed executable names when practical.

## Types and Values
- Respect NixOS/Home Manager option types; avoid implicit coercion.
- Keep booleans as booleans, lists as lists, and paths as paths/strings per option.
- Prefer explicit strings for env values and systemd text blocks.
- For structured inline data (e.g., PipeWire attrs), preserve existing shape/quoting.

## Error Handling and Safety
- Fail fast with clear messages in `runCommand` checks.
- Keep important invariants as `flake.nix` checks.
- For risky system changes, validate in this order:
  1) format/lint,
  2) `nix flake check`,
  3) `nixos-rebuild test`.
- Never commit plaintext secrets, tokens, private keys, or decrypted SOPS output.
- Secrets belong in `secrets/secrets.yaml` and should be referenced via `sops.secrets`.

## Recommended Validation Flow
- For small edits in one module:
  1) `alejandra path/to/file.nix`
  2) `nix run nixpkgs#statix -- check path/to/file.nix`
  3) relevant single check from `checks.x86_64-linux`
- For broad edits affecting multiple modules:
  1) `alejandra .`
  2) `nix run nixpkgs#deadnix -- .`
  3) `nix flake check --show-trace`

## CI Expectations
GitHub Actions currently enforces:
- `alejandra --check .`
- `deadnix -- .`
- `statix -- check .`
- `nix flake check --show-trace`
- Build of host `framework`

## Agent Workflow Checklist
- Read `flake.nix`, relevant module(s), and host file before editing.
- Make minimal, targeted edits that match nearby style.
- Run format + lint + relevant single checks for touched areas.
- Prefer single-check feedback first, then full `nix flake check`.
- Include changed paths and exact verification commands in final reports.
