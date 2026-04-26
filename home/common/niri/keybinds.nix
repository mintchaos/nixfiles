{ ... }:
{
  # Key format: modifiers separated by + signs, followed by XKB key name.
  # Use `wev` to find XKB key names.
  # "Mod" is Super on TTY, Alt when running as a winit window.
  programs.niri.settings.binds = {
    "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

    # Application launchers
    "Mod+Space" = {
      hotkey-overlay.title = "Run DMS launcer";
      action.spawn = [
        "dms" 
        "ipc" 
        "call" 
        "spotlight" 
        "toggle"
      ];
    };
    "Mod+T" = {
      hotkey-overlay.title = "Open a Terminal: ghostty";
      action.spawn = "ghostty";
    };
    "Mod+D" = {
      hotkey-overlay.title = "Run an Application: fuzzel";
      action.spawn = "fuzzel";
    };
    "Super+Alt+L" = {
      hotkey-overlay.title = "Lock the Screen: swaylock";
      action.spawn = "swaylock";
    };

    # Media keys - allow-when-locked makes them work even when session is locked
    "XF86AudioRaiseVolume" = {
      allow-when-locked = true;
      action.spawn = [
        "wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "0.1+"
      ];
    };
    "XF86AudioLowerVolume" = {
      allow-when-locked = true;
      action.spawn = [
        "wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "0.1-"
      ];
    };
    "XF86AudioMute" = {
      allow-when-locked = true;
      action.spawn = [
        "wpctl"
        "set-mute"
        "@DEFAULT_AUDIO_SINK@"
        "toggle"
      ];
    };
    "XF86AudioMicMute" = {
      allow-when-locked = true;
      action.spawn = [
        "wpctl"
        "set-mute"
        "@DEFAULT_AUDIO_SOURCE@"
        "toggle"
      ];
    };

    "XF86MonBrightnessUp" = {
      allow-when-locked = true;
      action.spawn = [
        "brightnessctl"
        "--class=backlight"
        "set"
        "+10%"
      ];
    };
    "XF86MonBrightnessDown" = {
      allow-when-locked = true;
      action.spawn = [
        "brightnessctl"
        "--class=backlight"
        "set"
        "10%-"
      ];
    };

    # Overview: zoomed-out view of workspaces and windows.
    # Also accessible via top-left hot corner or four-finger swipe up.
    "Mod+O" = {
      repeat = false;
      action.toggle-overview = [ ];
    };

    "Mod+Q" = {
      repeat = false;
      action.close-window = [ ];
    };

    "Mod+Left".action.focus-column-left = [ ];
    "Mod+Down".action.focus-window-down = [ ];
    "Mod+Up".action.focus-window-up = [ ];
    "Mod+Right".action.focus-column-right = [ ];
    "Mod+H".action.focus-column-left = [ ];
    "Mod+L".action.focus-column-right = [ ];

    "Mod+Ctrl+Left".action.move-column-left = [ ];
    "Mod+Ctrl+Down".action.move-window-down = [ ];
    "Mod+Ctrl+Up".action.move-window-up = [ ];
    "Mod+Ctrl+Right".action.move-column-right = [ ];
    "Mod+Ctrl+H".action.move-column-left = [ ];
    "Mod+Ctrl+L".action.move-column-right = [ ];

    # Alternative commands that move across workspaces when reaching first/last window in column
    "Mod+J".action.focus-window-or-workspace-down = [ ];
    "Mod+K".action.focus-window-or-workspace-up = [ ];
    "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = [ ];
    "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = [ ];

    "Mod+Home".action.focus-column-first = [ ];
    "Mod+End".action.focus-column-last = [ ];
    "Mod+Ctrl+Home".action.move-column-to-first = [ ];
    "Mod+Ctrl+End".action.move-column-to-last = [ ];

    "Mod+Shift+Left".action.focus-monitor-left = [ ];
    "Mod+Shift+Down".action.focus-monitor-down = [ ];
    "Mod+Shift+Up".action.focus-monitor-up = [ ];
    "Mod+Shift+Right".action.focus-monitor-right = [ ];
    "Mod+Shift+H".action.focus-monitor-left = [ ];
    "Mod+Shift+J".action.focus-monitor-down = [ ];
    "Mod+Shift+K".action.focus-monitor-up = [ ];
    "Mod+Shift+L".action.focus-monitor-right = [ ];

    "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
    "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
    "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
    "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
    "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
    "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
    "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
    "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

    "Mod+Page_Down".action.focus-workspace-down = [ ];
    "Mod+Page_Up".action.focus-workspace-up = [ ];
    "Mod+U".action.focus-workspace-down = [ ];
    "Mod+I".action.focus-workspace-up = [ ];
    "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
    "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
    "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
    "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

    "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
    "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
    "Mod+Shift+U".action.move-workspace-down = [ ];
    "Mod+Shift+I".action.move-workspace-up = [ ];

    # Mouse wheel binds - cooldown-ms prevents scrolling through workspaces too fast
    "Mod+WheelScrollDown" = {
      cooldown-ms = 150;
      action.focus-workspace-down = [ ];
    };
    "Mod+WheelScrollUp" = {
      cooldown-ms = 150;
      action.focus-workspace-up = [ ];
    };
    "Mod+Ctrl+WheelScrollDown" = {
      cooldown-ms = 150;
      action.move-column-to-workspace-down = [ ];
    };
    "Mod+Ctrl+WheelScrollUp" = {
      cooldown-ms = 150;
      action.move-column-to-workspace-up = [ ];
    };

    "Mod+WheelScrollRight".action.focus-column-right = [ ];
    "Mod+WheelScrollLeft".action.focus-column-left = [ ];
    "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
    "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

    # Shift+scroll replicates horizontal scrolling behavior
    "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
    "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
    "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
    "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

    # Dynamic workspace system: indices beyond current count refer to bottommost empty workspace
    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;

    "Mod+Ctrl+1".action.move-column-to-workspace = 1;
    "Mod+Ctrl+2".action.move-column-to-workspace = 2;
    "Mod+Ctrl+3".action.move-column-to-workspace = 3;
    "Mod+Ctrl+4".action.move-column-to-workspace = 4;
    "Mod+Ctrl+5".action.move-column-to-workspace = 5;
    "Mod+Ctrl+6".action.move-column-to-workspace = 6;
    "Mod+Ctrl+7".action.move-column-to-workspace = 7;
    "Mod+Ctrl+8".action.move-column-to-workspace = 8;
    "Mod+Ctrl+9".action.move-column-to-workspace = 9;

    # Move focused window in/out of column: consume into nearby column if alone, expel if in column
    "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
    "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

    # Consume window from right to bottom of focused column, or expel bottom window to right
    "Mod+Comma".action.consume-window-into-column = [ ];
    "Mod+Period".action.expel-window-from-column = [ ];

    "Mod+R".action.switch-preset-column-width = [ ];
    "Mod+Shift+R".action.switch-preset-window-height = [ ];
    "Mod+Ctrl+R".action.reset-window-height = [ ];
    "Mod+F".action.maximize-column = [ ];
    "Mod+Shift+F".action.fullscreen-window = [ ];
    # Expand column to fill remaining space not taken by other fully visible columns
    "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];

    "Mod+C".action.center-column = [ ];
    "Mod+Ctrl+C".action.center-visible-columns = [ ];

    # Width/height adjustments: can use pixels ("1000", "-5") or percentage ("-10%", "+10%")
    "Mod+Minus".action.set-column-width = "-10%";
    "Mod+Equal".action.set-column-width = "+10%";
    "Mod+Shift+Minus".action.set-window-height = "-10%";
    "Mod+Shift+Equal".action.set-window-height = "+10%";

    # Toggle floating/tiling layout
    "Mod+V".action.toggle-window-floating = [ ];
    "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

    # Toggle tabbed column display - windows appear as vertical tabs
    "Mod+W".action.toggle-column-tabbed-display = [ ];

    # Screenshots
    "Mod+Shift+Ctrl+Alt+1".action.screenshot = [ ];
    "Mod+Shift+Ctrl+Alt+2".action.screenshot-screen = [ ];
    "Mod+Shift+Ctrl+Alt+3".action.screenshot-window = [ ];

    # Screen casting: cast focused window, monitor, or clear cast target
    "Mod+Shift+Ctrl+Alt+W".action.set-dynamic-cast-window = [ ];
    "Mod+Shift+Ctrl+Alt+E".action.set-dynamic-cast-monitor = [ ];
    "Mod+Shift+Ctrl+Alt+Q".action.clear-dynamic-cast-target = [ ];

    # Escape hatch for keyboard shortcuts inhibitor - allows regaining control from buggy apps
    "Mod+Escape" = {
      allow-inhibiting = false;
      action.toggle-keyboard-shortcuts-inhibit = [ ];
    };

    # Quit shows confirmation dialog to avoid accidental exits
    "Mod+Shift+E".action.quit = [ ];
    "Ctrl+Alt+Delete".action.quit = [ ];

    # Powers off monitors; any input turns them back on
    "Mod+Shift+P".action.power-off-monitors = [ ];
  };
}
