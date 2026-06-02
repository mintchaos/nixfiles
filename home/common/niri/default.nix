{
  config,
  pkgs,
  inputs,
  nixpkgs-unstable,
  ...
}:
{
  imports = [
    ./spawn.nix
    ./outputs.nix
    ./input.nix
    ./layout.nix
    ./window-rules.nix
    ./keybinds.nix
    inputs.dms.homeModules.dank-material-shell
    inputs.dms-plugin-registry.modules.default
    inputs.dms.homeModules.niri
    inputs.cider-mpris.homeModules.cider-mpris
  ];

  services.cider-mpris = {
    enable = true;
    package = inputs.cider-mpris.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  programs.dank-material-shell = {
    enable = true;

    niri = {
      enableSpawn = true;
    };

    enableSystemMonitoring = true;
    dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

    plugins = {
      niriWindows.enable = true;
      calculator.enable = true;
      musicLyrics.enable = true;
    };
  };

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
