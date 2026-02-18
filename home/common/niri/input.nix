{ ... }:
{
  programs.niri.settings.input = {
    keyboard = {
      numlock = true;
    };

    touchpad = {
      tap = true;
      natural-scroll = true;
    };

    # Warp mouse to the center of newly focused windows
    warp-mouse-to-focus.enable = true;

    # Focus windows and outputs automatically when moving the mouse into them.
    # Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
    focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "0%";
    };
  };
}
