{ pkgs, ... }:

let
  i3statusCfg = import ./common/i3status-rust.nix;
in
{
  # External monitor management
  # programs.autorandr = import ./config/autorandr.nix;

  home.stateVersion = "24.05";

  imports = [
    ./common/wayland.nix
    ./common/apps.nix
  ];

  xresources.properties = {
    # Doesn't seem like most things need this, but flatpak electron apps do.
  };

}
