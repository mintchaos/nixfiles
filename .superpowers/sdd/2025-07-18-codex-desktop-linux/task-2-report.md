# Task 2 Report

## Changes in `home/common/apps.nix`

### Imports

Before:
```nix
imports = [ inputs.zen-browser.homeModules.beta ];
```

After:
```nix
imports = [
  inputs.zen-browser.homeModules.beta
  inputs.codex-desktop-linux.homeManagerModules.default
];
```

### Added `programs.codexDesktopLinux`

Inserted after `programs.zen-browser.nativeMessagingHosts`:
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

## Build attempt

- `nix fmt --check home/common/apps.nix` was not supported by this Nix installation (`nix fmt` rejected `--check`).
- `nh home build .` ran for 30 minutes and timed out during downloads without surfacing a module/configuration error.

## Commit

- Commit hash: `56bcf90`
