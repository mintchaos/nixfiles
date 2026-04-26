{ ... }:
{
  programs.niri.settings.layout = {
    gaps = 10;
    background-color = "#000000";

    # When to center a column when changing focus:
    # - "never": focusing an off-screen column keeps it at the left/right edge
    # - "always": the focused column will always be centered
    # - "on-overflow": center if it doesn't fit with the previously focused column
    center-focused-column = "on-overflow";
    always-center-single-column = true;

    # Widths that "switch-preset-column-width" (Mod+R) toggles between.
    # Proportion sets width as a fraction of output width, taking gaps into account.
    preset-column-widths = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];

    default-column-width.proportion = 0.33333;

    # By default focus ring and border are rendered as a solid background rectangle
    # behind windows, showing through semitransparent windows. This is because
    # windows with client-side decorations can have arbitrary shapes.
    # With prefer-no-csd, niri draws decorations *around* windows instead.
    focus-ring = {
      enable = false;
      width = 2;
      active.color = "#7fc8ff";
      inactive.color = "#505050";
    };

    border = {
      enable = true;
      width = 2;
      active.color = "#8e5db1";
      inactive.color = "#505050";
      urgent.color = "#9b0000";
    };

    shadow = {
      enable = true;
      softness = 30;
      spread = 5;
      offset = {
        x = 0;
        y = 5;
      };
      color = "#0007";
    };

    # Struts shrink the area occupied by windows, like layer-shell panels.
    # Left/right struts keep the next window to the side always visible.
    # Top/bottom struts add outer gaps in addition to layer-shell panels.
    struts = {
      # left = -6;
      # right = -6;
      # top = -6;
    };
  };

  programs.niri.settings.overview.zoom = 0.5;

  programs.niri.settings.animations.enable = true;
}
