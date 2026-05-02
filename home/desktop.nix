{ pkgs, inputs, ... }:
{
  home.username = "xian";
  home.homeDirectory = "/home/xian";
  home.stateVersion = "24.05";

  imports = [
    # NOTE: inputs.niri.homeModules.niri is NOT imported here because
    # inputs.niri.nixosModules.niri (imported via desktop-niri.nix) already
    # pushes it via home-manager.sharedModules for the NixOS build path.
    # The standalone home-manager path adds it in flake.nix.
    inputs.vicinae.homeManagerModules.default
    ./common/wayland.nix
    ./common/apps.nix
    ./common/niri
  ];

  xresources.properties = {
    # Doesn't seem like most things need this, but flatpak electron apps do.
  };

}
