{ ... }:
{
  programs.niri.settings.layer-rules = [
    {
      matches = [ { namespace = "^launcher$"; } ];
    }
  ];

  programs.niri.settings.window-rules = [
    # Work around WezTerm's initial configure bug by setting an empty default-column-width.
    # Regex is intentionally specific to avoid false positives.
    {
      matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
      default-column-width = { };
    }
    # Open Firefox picture-in-picture player as floating.
    # Regex matches both host Firefox ("firefox") and Flatpak Firefox ("org.mozilla.firefox").
    {
      matches = [
        {
          app-id = "firefox$";
          title = "^Picture-in-Picture$";
        }
      ];
      open-floating = true;
    }
    # The Artisan of Glimmith: keep the game windowed for keyboard input, then fullscreen it in Niri.
    {
      matches = [ { app-id = "steam_app_4160210"; } ];
      open-fullscreen = true;
    }
    {
      matches = [ { app-id = "steam_app_1808500"; } ];
      open-fullscreen = true;
    }
    {
      matches = [ { app-id = "steam"; } ];
      open-focused = false;
    }
    {
      matches = [
        { app-id = "steam"; }
        {
          app-id = "steam";
          title = "Friends List";
        }
      ];
      default-column-width.proportion = 0.166665;
    }
    {
      matches = [
        {
          app-id = "steam";
          title = "Steam";
        }
      ];
      default-column-width.proportion = 0.6666;
    }
    # Highlight windows being screen-cast with distinctive border/shadow styling.
    {
      matches = [ { is-window-cast-target = true; } ];
      focus-ring = {
        enable = false;
        width = 4;
        active.color = "#f38ba8";
        inactive.color = "#7d0d2d";
      };
      border = {
        enable = true;
        width = 4;
        active.color = "#f38ba8";
        inactive.color = "#7d0d2d";
      };
      shadow = {
        spread = 10;
        color = "#7d0d2d80";
      };
      tab-indicator = {
        active.color = "#f38ba8";
        inactive.color = "#7d0d2d";
      };
    }
    # Rounded corners for all windows.
    {
      geometry-corner-radius = {
        bottom-left = 6.0;
        bottom-right = 6.0;
        top-left = 6.0;
        top-right = 6.0;
      };
      clip-to-geometry = true;
    }
  ];
}
