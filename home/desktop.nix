{ pkgs, inputs, ... }:

let
  i3statusCfg = import ./common/i3status-rust.nix;
in
{
  home.username = "xian";
  home.homeDirectory = "/home/xian";
  home.stateVersion = "24.05";

  imports = [
    inputs.niri.homeModules.niri
    inputs.vicinae.homeManagerModules.default
    ./common/wayland.nix
    ./common/apps.nix
    ./common/niri
  ];

  xresources.properties = {
    # Doesn't seem like most things need this, but flatpak electron apps do.
  };

}
