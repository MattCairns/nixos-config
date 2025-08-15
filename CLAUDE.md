# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS configuration repository using flakes and home-manager to manage system and user configurations across multiple machines (framework laptop, ThinkPad laptop, Intel NUC, and cache-runner).

## Architecture

### Flake Structure
- `flake.nix`: Main entry point defining inputs (nixpkgs, home-manager, hyprland, nixvim, etc.) and outputs
- `machines/default.nix`: Defines machine configurations (framework, laptop, nuc, cache-runner)
- `config/`: Shared configuration files
  - `base.nix`: System-wide NixOS configuration
  - `home.nix`: Home-manager user configuration
  - `optin-persistence.nix`: Impermanence configuration
  - `users.nix`: User definitions

### Module Organization
- `modules/`: Modular home-manager configurations
  - `dev/`: Development tools (nixvim, git, terminals, shells)
  - `desktop/`: Desktop environment (hyprland, waybar)
  - `apps/`: Applications (firefox)

### Machine-Specific Configurations
Each machine has its own directory in `machines/` containing:
- `configuration.nix`: Machine-specific NixOS config
- `hardware-configuration.nix`: Hardware-specific settings

## Common Commands

### System Management
```bash
# Switch to new configuration for specific machine
sudo nixos-rebuild switch --flake .#<MACHINE>

# Test configuration without switching
sudo nixos-rebuild test --flake .#<MACHINE>

# Update flake inputs
nix flake update

# Format Nix files
alejandra .

# Garbage collect old generations
sudo nix-collect-garbage -d
```

### Development Workflow
```bash
# Edit configuration
nvim flake.nix

# Check flake
nix flake check

# Build configuration without switching
nixos-rebuild build --flake .#<MACHINE>
```

### Available Machines
- `framework`: Framework 13 AMD laptop
- `laptop`: ThinkPad L13 Yoga
- `nuc`: Intel NUC desktop
- `cache-runner`: Headless cache server

## Key Features

### Secret Management
Uses sops-nix for managing secrets:
- Secrets defined in `secrets/secrets.yaml`
- Keys referenced in `config/home.nix` sops configuration
- SSH keys located at `/home/matthew/.ssh/id_ed25519`

### Custom Scripts
Located in `scripts/` and available in PATH:
- `tmux-sessionizer`: Project session management
- `tmux-windowizer`: Window management
- `chwall`: Wallpaper changer
- Various tmux utilities

### Persistence
Uses impermanence with opt-in persistence via `config/optin-persistence.nix`

## Editor Configuration
- Primary editor: nixvim (located in `modules/dev/nixvim/`)
- Configured with LSP, treesitter, completion, and debugging
- Alternative neovim config available but commented out in `modules/default.nix`

## Environment Variables
Key variables set in `config/base.nix`:
- `FLAKE`: Points to `$HOME/nixos-config`
- `EDITOR`: Set to `nvim`
- XDG directories configured

## Installation Process
1. Clone repository to `~/nixos-config`
2. Copy hardware configuration: `cp /etc/nixos/hardware-configuration.nix ~/nixos-config/machines/<MACHINE>/.`
3. Switch: `sudo nixos-rebuild switch --flake .#<MACHINE>`
4. Reboot