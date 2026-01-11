# AGENTS.md

This file contains guidelines and commands for agentic coding agents working in this NixOS configuration repository.

## Repository Overview

This is a personal NixOS system configuration repository using Nix flakes. The repository contains system-level configurations, home-manager user configurations, and hardware-specific settings for a NixOS setup with full disk encryption.

**Key characteristics:**
- NixOS flake-based configuration
- Wayland-focused desktop environments (Niri, i3, Sway)
- Full disk encryption with LUKS1
- Home-manager integration for user configurations
- Hardware-specific optimizations for ThinkPad X1 Carbon

## Build and Management Commands

### System Configuration
```bash
# Build and switch to new configuration (primary command)
sudo nixos-rebuild switch --flake .

# Dry-run build to test changes without applying
sudo nixos-rebuild dry-build --flake .

# Build and switch with upgrade flag
sudo nixos-rebuild switch --flake . --upgrade

# Build configuration (no switch)
sudo nixos-rebuild build --flake .

# Test configuration (doesn't persist on reboot)
sudo nixos-rebuild test --flake .

# Build specific host configuration
sudo nixos-rebuild switch --flake .#the-spine
```

### Home Manager
```bash
# Switch home-manager configuration using flakes
home-manager switch --flake .

# Build home-manager configuration using flakes
home-manager build --flake .

# Switch specific user configuration
home-manager switch --flake .#xian@the-spine

# Expire old generations (cleanup)
home-manager expire-generations "-7 days"
```

### Package Management
```bash
# Update flake inputs
nix flake update

# Update all packages (system + user + flatpak)
make update

# Check for outdated packages
make outdated

# Clean old garbage
make clean

# Update specific flake input
nix flake update nixpkgs
```

### Using Makefile
```bash
# Full system update (system + user + flatpak)
make update

# Check for outdated packages
make outdated

# Clean old generations
make clean

# Generate password hash
make password

# Generate configuration for specific host
make config HOST=the-spine
```

### Testing and Validation
```bash
# Test flake configuration syntax
nix flake check

# Validate flake outputs
nix flake show

# List flake outputs
nix flake metadata

# Dry-run build with upgrade
sudo nixos-rebuild dry-build --flake . --upgrade

# Build specific configuration without switching
nix build .#nixosConfigurations.the-spine.config.system.build.toplevel
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

#### Option Definitions
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
- **Build failures**: Check `nixos-rebuild dry-build` first
- **Missing inputs**: Run `nix flake update` 
- **Hardware issues**: Check hardware-specific configurations
- **Permission errors**: Ensure proper file permissions for security files

### Debugging
- Use `nixos-rebuild build --show-trace` for detailed errors
- Check `/nix/var/log/nixos/` for build logs
- Use `nix flake check` to validate flake structure
- Test with `nixos-rebuild test` before switching

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

### Development Setup
- Rust development shell available
- Uses `nixfmt` for Nix formatting
- Git integration with delta
- VS Code with Nix environment selector

### Hardware Optimizations
- ThinkPad X1 Carbon specific configurations
- AMD GPU support with ROCm
- Xbox controller support with xone
- Power management optimizations

## Testing Strategy

Since this is a system configuration repository, testing involves:
1. **Syntax validation**: `nix flake check`
2. **Dry-run builds**: `sudo nixos-rebuild dry-build --flake`
3. **Test configurations**: `sudo nixos-rebuild test --flake`
4. **Manual verification**: Check system functionality after changes

Always run dry-build before applying system changes, especially for boot-related configurations.

## Reference Documentation

- [NixOS Manual](https://nix.dev/manual/nix/2.33/nix-2.33.html)
- [NixOS Wiki](https://nixos.wiki/)
- [NixOS Configuration Examples](https://github.com/NixOS/nixos-configurations)
