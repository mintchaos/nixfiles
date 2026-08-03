# Codex Desktop Linux — Declarative Home-Manager Integration

## Summary

Add declarative home-manager configuration for the ChatGPT Desktop Linux app
(`ilysenko/codex-desktop-linux`) with the community Nix-native CLI
(`sadjow/codex-cli-nix`) and the remote-control systemd user service.

## Motivation

ChatGPT Desktop for Linux provides a native desktop experience with features
like AppShots capture, remote mobile control, and compositor integration. The
upstream flake supports home-manager and NixOS modules for declarative setup.

We want the desktop app, the CLI it depends on, and the remote-control
app-server managed as a user systemd service — all defined declaratively in
home-manager.

## Design

### Flake Inputs

Two new inputs in `flake.nix`:

- `codex-desktop-linux` — `github:ilysenko/codex-desktop-linux/main`
- `codex-cli-nix` — `github:sadjow/codex-cli-nix/main` with `nixpkgs.follows = "nixpkgs"`

No `flake-utils.follows` needed — we don't use `flake-utils` as a top-level
input, so we let the CLI flake resolve its own.

### Cachix Cache

Add `codex-cli.cachix.org` substituter and public key to `nixConfig` in
`flake.nix`. The `codex-desktop-linux` cache key is not documented in the
upstream guide, so we omit it for now.

### Home-Manager Module

In `home/common/apps.nix`:

1. Import `inputs.codex-desktop-linux.homeManagerModules.default`
2. Configure `programs.codexDesktopLinux`:
   - `enable = true`
   - `cliPackage` — wired to `codex-cli-nix` default package, bakes `CODEX_CLI_PATH` into the launcher
   - `remoteControl.enable = true` with same CLI package
   - `remoteMobileControl.enable = true`
   - `linuxFeatures` — appshots, directory-only-working-tree-watch, frameless-titlebar, mcp-helper-reaper, node-repl-reaper, open-target-discovery, persistent-status-panel, remote-mobile-control

### What We're NOT Including

- `codex-micro` — Work Louder hardware we don't have
- `computerUseUi.enable` — skipping for now, can add later
- NixOS-level module — user-level services don't need system-level config
- `codex-desktop-linux` Cachix cache — upstream doesn't document the key

## Files Changed

- `flake.nix` — two new inputs, one new substituter + key
- `flake.lock` — updated by `nix flake update`
- `home/common/apps.nix` — module import + `programs.codexDesktopLinux` block

## Testing

1. `nix flake check` — syntax validation
2. `nh home build .` — dry-run home-manager build
3. `nh home switch .` — activate and verify the app launches, CLI is found, remote-control service starts
