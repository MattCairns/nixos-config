# AGENTS.md

Guide for coding agents working in this NixOS + Home Manager flake.

## Hosts
Defined in `machines/default.nix`:
- `framework`: Framework 13 AMD laptop (daily driver).
- `desktop`: NVIDIA desktop, installed with `nix run .#install-desktop` (disko). Slow to build (CUDA); evaluate instead of building unless asked:
  `nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath`

## Layout
- `flake.nix`: inputs, packages (`install-desktop`, `hypruse`), formatter.
- `machines/default.nix`: `mkHost`. Every host gets `config/base.nix`, `config/users.nix`, `config/optin-persistence.nix`, disko, sops, and Home Manager. `user` and `inputs` are passed as specialArgs to both NixOS and HM modules.
- `machines/<host>/configuration.nix`: host-only settings.
- `config/base.nix`: shared NixOS settings. `config/home.nix`: shared HM settings and package list.
- `config/disko.nix`: reusable disk layout (EFI + swap + LUKS → btrfs subvolumes).
- `config/optin-persistence.nix`: impermanence; `/` is rolled back to `root-blank` on boot, so state that must survive goes under `/persist`.
- `modules/`: HM modules (`dev/`, `desktop/`, `apps/`), wired up in `modules/default.nix`.
- `modules/dev/skills/`: agent skills shared by Claude Code and opencode.
- `scripts/*.nix`: `{pkgs}: writeShellScriptBin ...` scripts, added to `home.packages` via `callPackage` in `config/home.nix`. `scripts/bin/` is linked to `~/.config/bin`.

## Secrets
sops-nix, HM level only. Secrets live in `secrets/secrets.yaml`, decrypted with `~/.ssh/id_ed25519`, and are declared in `sops.secrets` in `config/home.nix`. Never commit plaintext secrets or decrypted output.

## Commands
- Format: `alejandra .`
- Lint (CI): `alejandra --check .`, `nix run nixpkgs#deadnix -- .`, `nix run nixpkgs#statix -- check .`
- Check: `nix flake check --show-trace`
- Build: `nix build .#nixosConfigurations.framework.config.system.build.toplevel`
- Apply: `nh os test` / `nh os switch` (or `nixos-rebuild test|switch --flake .#framework`; runs without a sudo password). Use `test` first for boot/kernel/display/network/auth changes.
- Update inputs: `nix flake update`

## Style
- `alejandra` formatting is the source of truth.
- Remove unused arguments (deadnix runs in CI).
- Use `user` / `config.home.homeDirectory` / `config.xdg.configHome` rather than hardcoding `matthew` or `/home/matthew`.
- Use `let ... in` for values reused more than once, and prefer `inherit`.
- Keep module files as `<name>/default.nix` and add new ones to `modules/default.nix`.
