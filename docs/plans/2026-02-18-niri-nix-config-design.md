# Niri Nix-Native Configuration Migration Design

## Goal

Convert `~/.config/niri/config.kdl` to Nix-native configuration using niri-flake's `programs.niri.settings` options. All behavior should be maintained and organized for easy maintenance.

## File Structure

```
home/common/niri/
├── default.nix      # Main config - imports all others, defines programs.niri.settings
├── keybinds.nix     # All 80+ keybindings
├── window-rules.nix # Window rules (wezterm, firefox pip, steam, screen capture, rounded corners)
├── layout.nix       # Gaps, colors, focus-ring, border, shadow, struts
├── input.nix        # Keyboard, touchpad, mouse, trackpoint, focus-follows-mouse
├── outputs.nix      # Output configuration (eDP-1 disabled by default)
└── spawn.nix        # spawn-at-startup commands
```

## Module Pattern

Each sub-module exports settings that are merged via Nix module system:

```nix
# home/common/niri/keybinds.nix
{ ... }:
{
  "Mod+T".action.spawn = "ghostty";
  "Mod+D".action.spawn = "fuzzel";
}

# home/common/niri/default.nix
{ pkgs, ... }:
{
  imports = [ ./keybinds.nix ./window-rules.nix ./layout.nix ./input.nix ./outputs.nix ./spawn.nix ];
  
  programs.niri.enable = true;
  programs.niri.settings = {
    prefer-no-csd = true;
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
  };
}
```

## Keybind Organization

Keybinds grouped by function with comments:

```nix
{
  # Application launchers
  "Mod+T".action.spawn = "ghostty";
  
  # Media keys
  "XF86AudioRaiseVolume" = { action.spawn = ["wpctl" "set-volume" ...]; allow-when-locked = true; };
  
  # Window navigation
  "Mod+Left".action.focus-column-left = [];
  
  # Workspace switching
  "Mod+1".action.focus-workspace = 1;
  
  # Screenshots
  "Mod+Shift+Ctrl+Alt+1".action.screenshot = [];
}
```

## What Moves Where

### From `common/desktop-niri.nix` to `home/common/niri/default.nix`:
- `programs.niri.enable = true` (home-manager takes ownership)

### Stays in `common/desktop-niri.nix`:
- `nixpkgs.overlays` (must be system-level)
- `environment.variables` (XDG_SESSION_DESKTOP, etc.)
- `services.greetd` (display manager)
- `environment.systemPackages` (wl-clipboard, fuzzel, xwayland-satellite, etc.)
- `xdg.portal` configuration
- `security.pam.services.swaylock`

### From `~/.config/niri/config.kdl`:
- All settings → `home/common/niri/*.nix` files
- After migration, KDL file can be deleted (Nix generates it)

### From KDL to Nix files mapping:
| KDL Section | Nix File |
|-------------|----------|
| environment | spawn.nix (DISPLAY var) |
| input | input.nix |
| overview | layout.nix |
| output | outputs.nix |
| layout | layout.nix |
| spawn-at-startup | spawn.nix |
| hotkey-overlay | default.nix |
| prefer-no-csd | default.nix |
| screenshot-path | default.nix |
| animations | layout.nix |
| layer-rule | window-rules.nix |
| window-rule | window-rules.nix |
| binds | keybinds.nix |

## Migration Steps

1. Create `home/common/niri/` directory structure
2. Convert each KDL section to corresponding Nix file
3. Add import to `home/desktop.nix`
4. Remove `programs.niri.enable` from `common/desktop-niri.nix`
5. Test with `nixos-rebuild dry-build --flake .`
6. Delete `~/.config/niri/config.kdl`

## Notes

- The eDP-1 output config is included but disabled by default (as it was in KDL)
- The niri-flake overlay stays at system level for proper mesa dependency handling
- Home-manager's niri module automatically generates `$XDG_CONFIG_HOME/niri/config.kdl`
