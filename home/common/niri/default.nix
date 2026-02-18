{ pkgs, ... }:
{
  imports = [
    ./spawn.nix
    ./outputs.nix
    ./input.nix
    ./layout.nix
    ./window-rules.nix
    ./keybinds.nix
  ];

  programs.niri.settings = {
    # Ask clients to omit client-side decorations if possible.
    # Clients informed they are tiled will remove some client-side rounded corners.
    # Also fixes border/focus ring drawing behind semitransparent windows.
    # Restart apps after changing this for it to take effect.
    prefer-no-csd = true;

    # Screenshot path with strftime(3) formatting. Use null to disable saving to disk.
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    hotkey-overlay.skip-at-startup = false;
  };
}
