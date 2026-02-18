{ ... }:
{
  # Find output names by running `niri msg outputs` while inside a niri instance.
  # The built-in laptop monitor is usually called "eDP-1".
  # See: https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs
  programs.niri.settings.outputs = {
    # Example output configuration for eDP-1 (commented out - niri will auto-configure)
    # eDP-1 = {
    #   mode = {
    #     width = 1920;
    #     height = 1080;
    #     refresh = 120.030;
    #   };
    #   scale = 2.0;
    #   transform.rotation = 0;
    #   # Position in global coordinate space. Affects directional monitor actions
    #   # and cursor movement. Output scale must be considered: outputs are sized
    #   # in logical pixels. E.g., a 3840x2160 output with scale 2.0 has logical
    #   # size 1920x1080, so place another output to its right by setting x=1920.
    #   position = {
    #     x = 1280;
    #     y = 0;
    #   };
    # };
  };
}
