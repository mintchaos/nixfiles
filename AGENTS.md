# AGENTS.md

This file contains guidelines and commands for agentic coding agents working in this NixOS configuration repository.

## Repository Overview

This is a personal NixOS system configuration repository using Nix flakes. The repository contains system-level configurations, home-manager user configurations, and hardware-specific settings for a NixOS setup with full disk encryption.

**Key characteristics:**

- NixOS flake-based configuration
- Wayland-focused desktop environments (Niri, i3, Sway)
- Full disk encryption with LUKS1
- Home-manager integration for user configurations

## Build and Management Commands

Use `nh` for all builds. Include `-q`/`--quiet` on `nh` commands unless you need verbose output. Run `nh --help`, `nh os --help`, or `nh home --help` for full options.
Standard `nixos-rebuild` and `home-manager` are still available if needed.

### System

```bash
nh os switch      # build and activate, make boot default
nh os boot        # build and set as boot default (no activation)
nh os test        # build and activate (doesn't persist on reboot)
nh os build       # build only, don't activate
```

### Home Manager

```bash
nh home switch .  # build and activate
nh home build .   # build only
```

### Flake Management

```bash
nix flake update          # update all flake inputs
nix flake update nixpkgs  # update specific input
nix flake check           # validate flake syntax
nix flake show            # show flake outputs
nix flake metadata        # show flake metadata
```

### Cleanup

```bash
nh clean all    # clean all profiles (replaces nix-collect-garbage + home-manager expire-generations)
```

## Code Style Guidelines

### File Structure and Organization

- **System configs**: `common/` for shared system configurations
- **Host configs**: `hosts/` for host-specific configurations
- **User configs**: `home/` for home-manager configurations
- **Hardware configs**: `hardware/` for hardware-specific settings
- **Development shells**: `shells/` for development environments

### Nix Language Conventions

#### Module Structure

```nix
{ config, pkgs, lib, ... }: {
  # Configuration options here
}
```

#### Imports and Dependencies

- Use relative imports for local modules
- Flake inputs passed via `specialArgs` or `extraSpecialArgs`
- Standard pattern: `{ pkgs, inputs, ... }:` for modules needing inputs

#### Attribute Sets

- Use consistent indentation (2 spaces)
- Align attribute values when beneficial for readability
- Group related attributes together

#### Package Lists

```nix
environment.systemPackages = with pkgs; [
  # System tools
  git
  neovim
  tmux

  # Desktop applications
  firefox
  vscode
];
```

#### Service Configuration

- Enable services with `enable = true;`
- Use nested attribute sets for service settings
- Comment complex service configurations

#### Option Definitions!!

- Use `lib.mkDefault` for sensible defaults
- Use `lib.mkForce` only when necessary
- Provide descriptive comments for non-obvious options

### Naming Conventions

- **Files**: kebab-case (e.g., `desktop-niri.nix`, `thinkpad-x1c.nix`)
- **Variables**: camelCase for local variables, kebab-case for configuration options
- **Hosts**: kebab-case (e.g., `the-spine`, `xian-gamingboot`)
- **Users**: lowercase (e.g., `xian`)

### Import Patterns

```nix
# System configuration imports
imports = [
  ./common/desktop.nix
  ./hardware/thinkpad-x1c.nix
];

# Home-manager imports
imports = [
  ./common/wayland.nix
  ./common/apps.nix
];
```

### Comments and Documentation

- Use `#` for single-line comments
- Use multi-line comments for complex explanations
- Comment non-obvious configuration choices
- Document hardware-specific workarounds

### Security Practices

- Never commit secrets or keys
- Use `.hashedPassword.nix` for password hashes (chmod 400)
- Keep sensitive hardware configurations in separate files
- Use proper file permissions for security files

### Flake Conventions

- Use `nixos-unstable` channel for main packages
- Pin external inputs in `flake.lock`
- Pass inputs via `specialArgs` to modules
- Use descriptive flake descriptions

### Home Manager Patterns

- Use `home.stateVersion` for user configurations
- Import shared configurations from `home/common/`
- Use `home.file` for dotfile management
- Use `home.packages` with `with pkgs;` pattern

### Hardware Configuration

- Keep hardware-specific configs in `hardware/`
- Use descriptive filenames (e.g., `thinkpad-x1c.nix`)
- Document hardware-specific workarounds
- Use kernel module blacklisting when necessary

### Development Environment

- Use development shells in `shells/` directory
- Include build tools and linters in shells
- Use `nix develop` to enter development environments
- Document shell usage in comments

## Common Patterns

### Package Overrides

```nix
nixpkgs.config = {
  allowUnfree = true;
  packageOverrides = pkgs: {
    neovim = pkgs.neovim.override { vimAlias = true; };
  };
};
```

### Conditional Configuration

```nix
# Example: Enable different desktop environments
config = lib.mkIf (config.desktop.environment == "wayland") {
  # Wayland-specific configuration
};
```

### File Management

```nix
# Source files from config directory
home.file.".config/tmux.conf".source = ../config/tmux.conf;

# Generate files from text
home.file.".config/app/config.toml".text = ''
  [settings]
  option = "value"
'';
```

## Error Handling

### Common Issues

- **Build failures**: Try `nh os build` (dry-run without activating)
- **Missing inputs**: Run `nix flake update`
- **Hardware issues**: Check hardware-specific configurations
- **Permission errors**: Ensure proper file permissions for security files

### Debugging

- Use `nh os build -v` for verbose build output
- Check `/nix/var/log/nixos/` for build logs
- Use `nix flake check` to validate flake structure
- Test with `nh os test` before switching

## Repository-Specific Notes

### Full Disk Encryption

- Uses LUKS1 for GRUB compatibility
- Keyfile management via Makefile
- Separate encrypted swap partition
- Documented in README.md

### Window Manager Support

- Primary: Niri (Wayland)
- Secondary: i3, Sway configurations available
- Wayland-focused user configurations
- XDG portal integration for Wayland

#### Niri Keybind Rules

When adding niri keybindings in `programs.niri.settings.binds`:
- `action.spawn` must be an **array of strings**, not a single string with spaces
- Each argument is its own element (e.g., `["playerctl" "play-pause"]`, not `"playerctl play-pause"`)
- Single-word commands with no arguments can be a bare string (e.g., `"ghostty"`)

### Development Setup

- Rust development shell available
- Uses `nixfmt` for Nix formatting
- Git integration with delta
- VS Code with Nix environment selector

### Hardware Optimizations

- AMD GPU support with ROCm
- Xbox controller support with xone

## Testing Strategy

Since this is a system configuration repository, testing involves:

1. **Syntax validation**: `nix flake check`
2. **Dry-run builds**: `nh os build`
3. **Test configurations**: `nh os test`
4. **Manual verification**: Check system functionality after changes

Always run dry-build before applying system changes, especially for boot-related configurations.

## Reference Documentation

- [NixOS Manual](https://nix.dev/manual/nix/2.33/nix-2.33.html)
- [NixOS Wiki](https://nixos.wiki/)
- [NixOS Configuration Examples](https://github.com/NixOS/nixos-configurations)


