{ ... }:
{
  # Note: niri as a session supports xdg-desktop-autostart which may be more convenient.
  # Commands spawned here are put in transient systemd units when built with systemd feature.
  programs.niri.settings.spawn-at-startup = [
    { argv = [ "waybar" ]; }
    { argv = [ "xwayland-satellite" ]; }
  ];

  programs.niri.settings.environment = {
    DISPLAY = ":0";
  };
}
