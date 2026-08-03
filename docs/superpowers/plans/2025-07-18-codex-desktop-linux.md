# Codex Desktop Linux Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add declarative home-manager configuration for ChatGPT Desktop Linux with Nix-native CLI and remote-control systemd service.

**Architecture:** Two new flake inputs feed into the home-manager module from `codex-desktop-linux`. The `codex-cli-nix` package is wired via `cliPackage` and `remoteControl.package` so the desktop launcher and systemd service always find the `codex` binary regardless of PATH.

**Tech Stack:** Nix flakes, home-manager, codex-desktop-linux HM module, codex-cli-nix package

## Global Constraints

- Use `nh` for all builds (`nh home build .`, `nh home switch .`)
- Follow existing nixfiles patterns (2-space indent, `with pkgs;` for packages, `home/common/` for user config)
- Commit frequently with descriptive messages
- No `git add -A`; stage files explicitly

---

### Task 1: Add flake inputs and Cachix cache

**Files:**
- Modify: `flake.nix` — add two inputs, one substituter + key

**Interfaces:**
- Produces: `inputs.codex-desktop-linux` (flake with `homeManagerModules.default`), `inputs.codex-cli-nix` (flake with `packages.${system}.default`)

- [ ] **Step 1: Add `codex-desktop-linux` input to `flake.nix`**

In the `inputs` block, after the `zen-browser` input, add:

```nix
codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux/main";
```

- [ ] **Step 2: Add `codex-cli-nix` input to `flake.nix`**

After the `codex-desktop-linux` input, add:

```nix
codex-cli-nix = {
  url = "github:sadjow/codex-cli-nix/main";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

- [ ] **Step 3: Add `codex-cli` Cachix cache to `nixConfig`**

In the `nixConfig` block, add to `extra-substituters`:

```nix
"https://codex-cli.cachix.org"
```

Add to `extra-trusted-public-keys`:

```nix
"codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
```

- [ ] **Step 4: Update flake lock**

```bash
nix flake lock
```

This picks up the two new inputs without updating existing ones.

- [ ] **Step 5: Validate flake syntax**

```bash
nix flake check
```

Expected: no errors related to the new inputs or cache config.

- [ ] **Step 6: Commit**

```bash
git add flake.nix flake.lock
git commit -m "feat: add codex-desktop-linux and codex-cli-nix flake inputs"
```

---

### Task 2: Add home-manager module import and configuration

**Files:**
- Modify: `home/common/apps.nix` — add import and `programs.codexDesktopLinux` block

**Interfaces:**
- Consumes: `inputs.codex-desktop-linux.homeManagerModules.default`, `inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default`
- Produces: working `programs.codexDesktopLinux` configuration

- [ ] **Step 1: Add module import**

In `home/common/apps.nix`, change the `imports` list from:

```nix
imports = [ inputs.zen-browser.homeModules.beta ];
```

to:

```nix
imports = [
  inputs.zen-browser.homeModules.beta
  inputs.codex-desktop-linux.homeManagerModules.default
];
```

- [ ] **Step 2: Add `programs.codexDesktopLinux` configuration**

Add the following block after `programs.zen-browser.nativeMessagingHosts` (before `home.file`):

```nix
programs.codexDesktopLinux = {
  enable = true;
  cliPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  remoteControl = {
    enable = true;
    package = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  remoteMobileControl.enable = true;
  linuxFeatures = [
    "appshots"
    "directory-only-working-tree-watch"
    "frameless-titlebar"
    "mcp-helper-reaper"
    "node-repl-reaper"
    "open-target-discovery"
    "persistent-status-panel"
    "remote-mobile-control"
  ];
};
```

- [ ] **Step 3: Dry-run home-manager build**

```bash
nh home build .
```

Expected: build succeeds with no errors. The derivation should resolve all inputs.

- [ ] **Step 4: Commit**

```bash
git add home/common/apps.nix
git commit -m "feat: add codexDesktopLinux home-manager config with CLI + remote control"
```

---

### Task 3: Activate and verify

**Files:**
- None modified

**Interfaces:**
- Consumes: built home-manager generation from Task 2

- [ ] **Step 1: Activate the new home-manager generation**

```bash
nh home switch .
```

- [ ] **Step 2: Verify the Codex desktop application is installed**

```bash
which codex-desktop || ls ~/.nix-profile/bin/codex-desktop* || ls /run/current-system/sw/bin/codex-desktop*
```

Expected: binary exists in PATH or Nix profile.

- [ ] **Step 3: Verify the CLI is installed and CODEX_CLI_PATH is baked in**

```bash
cat $(which codex-desktop 2>/dev/null || echo ~/.nix-profile/bin/codex-desktop) | grep CODEX_CLI_PATH
```

Expected: wrapper script contains `CODEX_CLI_PATH` pointing at the `codex-cli-nix` store path.

- [ ] **Step 4: Verify the remote-control systemd service exists**

```bash
systemctl --user status codex-remote-control.service
```

Expected: service unit exists (may be inactive if not started). If it failed to start, check logs:

```bash
journalctl --user -u codex-remote-control.service -n 50
```

- [ ] **Step 5: Launch the desktop app**

```bash
codex-desktop &
```

Expected: app launches. Check launcher log if nothing visible happens:

```bash
sed -n '1,220p' ~/.cache/codex-desktop/launcher.log
```

- [ ] **Step 6: Commit any lock file updates if needed, then finalize**

```bash
git status
# If flake.lock changed:
git add flake.lock && git commit -m "chore: update flake.lock after codex activation"
```
