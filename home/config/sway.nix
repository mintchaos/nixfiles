{ pkgs, lib,

lockcmd ? "${pkgs.swaylock}/bin/swaylock -fF", ... }:
let
  mod = "Mod4";
  opt = "Mod1";
  hyper = "Mod4+Shift+Ctrl+Mod1";
  term = "ghostty";

  # sway port of xcwd
  # via: https://www.reddit.com/r/swaywm/comments/ayedi1/opening_terminals_at_the_same_directory/ei7i1dl/?context=1
  windowcwd = pkgs.writeScript "windowcwd" ''
    pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.type=="con") | select(.focused==true).pid')
    ppid=$(pgrep --newest --parent $pid)
    readlink /proc/$ppid/cwd || echo $HOME
  '';

  # FIXME: This doesn't actually work, but sounds like a good idea in theory lol
  darkmode = pkgs.writeScript "darkmode" ''
    export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
  '';

  # push-to-talk = pkgs.writeScript "push-to-talk" ''
  #   case $1 in
  #       on)
  #           pamixer --default-source -u
  #           pw-cat -p "${../../assets/sounds/ptt-activate.mp3}"
  #       ;;
  #       off)
  #           pamixer --default-source -m
  #           pw-cat -p "${../../assets/sounds/ptt-deactivate.mp3}"
  #       ;;
  #   esac
  # '';
in {
  modifier = mod;
  terminal = term;
  window.border = 2;
  window.hideEdgeBorders = "both";
  colors.background = "#000000";
  gaps = {
    inner = 10;
    outer = -10;
    bottom = 0;
    smartGaps = true;
  };
  fonts = {
    names = [ "DejaVu Sans Mono" "FontAwesome" ];
    style = "Bold Semi-Condensed";
    size = 10.0;
  };
  output = {
    # FIXME: This breaks flameshot?
    # Need something like QT_SCREEN_SCALE_FACTORS = builtins.toString (1 / 1.5);
    # "*" = { scale = "1.5"; };
  };
  input = {
    "type:touchpad" = {
      tap = "enabled";
      dwt = "enabled"; # Disable keyboard while typing
    };
  };
  startup = [
    { command = ''${pkgs.swaybg}/bin/swaybg --color "#000000"''; }
    { command = "${darkmode}"; }
  ];
  keybindings = lib.mkOptionDefault {
    # Special keys
    "XF86MonBrightnessUp" =
      "exec brightness up 10"; # TODO: Port wrapper using `ddcutil setvcp 10 + 5` on desktop?
    "XF86MonBrightnessDown" = "exec brightness down 10";
    "${mod}+XF86MonBrightnessUp" = "exec brightness up 5";
    "${mod}+XF86MonBrightnessDown" = "exec brightness down 5";
    "XF86AudioRaiseVolume" = "exec --no-startup-id pamixer --increase 5";
    "XF86AudioLowerVolume" = "exec --no-startup-id pamixer --decrease 5";
    "XF86AudioMute" = "exec --no-startup-id pamixer --toggle-mute";
    "XF86AudioMicMute" =
      "exec --no-startup-id pamixer --default-source --toggle-mute";
    "XF86AudioPlay" = "exec playerctl play-pause";
    "XF86AudioPause" = "exec playerctl pause";
    "XF86AudioNext" = "exec playerctl next";
    "XF86AudioPrev" = "exec playerctl previous";

    # There's a bug in the Framework that sends Super_L+p instead of XF86Display, so we duplicate the bindings -_-
    # https://community.frame.work/t/whats-up-with-the-display-switch-key/43078
    "XF86Display" = "exec rofi-screenlayout";
    "Mod4+p" = "exec rofi-screenlayout";
    "Shift+XF86Display" = "exec rofi-screenlayout _default"; # Reset screen
    "Shift+Mod4+p" = "exec rofi-screenlayout _default"; # Reset screen

    "${mod}+b" =
      "exec wl-paste | rofi -dmenu | xargs bookmark | xargs -I '{}' xdg-open obsidian://open/?path={}";
    "${mod}+n" = "exec note"; # Open latest note

    # Splits
    # "${mod}+h" = "splith";
    # "${mod}+v" = "splitv";

    # change focus
    "${mod}+h" = "focus left";
    "${mod}+j" = "focus down";
    "${mod}+k" = "focus up";
    "${mod}+l" = "focus right";

    # alternatively, you can use the cursor keys:
    "${mod}+Left" = "focus left";
    "${mod}+Down" = "focus down";
    "${mod}+Up" = "focus up";
    "${mod}+Right" = "focus right";

    # move focused window
    "${mod}+Shift+h" = "move left";
    "${mod}+Shift+j" = "move down";
    "${mod}+Shift+k" = "move up";
    "${mod}+Shift+l" = "move right";

    # alternatively, you can use the cursor keys:
    "${mod}+Shift+Left" = "move left";
    "${mod}+Shift+Down" = "move down";
    "${mod}+Shift+Up" = "move up";
    "${mod}+Shift+Right" = "move right";

    # split in horizontal orientation
    "${mod}+semicolon" = "split h";

    # split in vertical orientation
    "${mod}+v" = "split v";

    # enter fullscreen mode for the focused container
    "${mod}+f" = "fullscreen toggle";

    # change container layout (stacked, tabbed, toggle split)
    "${mod}+s" = "layout stacking";
    "${mod}+w" = "layout tabbed";
    "${mod}+e" = "layout toggle split";

    # toggle tiling / floating
    "${mod}+Shift+space" = "floating toggle";

    # change focus between tiling / floating windows
    "${mod}+Tab" = "focus mode_toggle";

    # Kill focused window
    "${mod}+Shift+q" = "kill";

    # Jump to urgent
    "${mod}+x" = "[urgent=latest] focus";

    # Rofi
    "${mod}+space" = "exec rofi -show run -p '$ '";
    "${mod}+Shift+Tab" = "exec rofi -show window -p '[window] '";
    "${mod}+Shift+v" =
      "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
    "${mod}+Shift+d" = ''
      exec cliphist list | dmenu | cliphist delete && notify-send "Deleted clipboard item"'';

    # Lock
    "${hyper}+l" = "exec ${lockcmd}";
    "${hyper}+p" = "exec systemctl suspend";
    "Print+l" = "exec ${lockcmd}";
    "XF86Launch2" = "exec ${lockcmd}";
    "${mod}+minus" = "exec ${lockcmd}";
    "${mod}+Shift+minus" = "exec systemctl suspend";

    # Emoji
    "${mod}+Mod1+space" =
      "exec --no-startup-id rofi -show emoji -modi emoji | wl-paste";

    # Screenshot
    "--release ${mod}+Print" = "exec flameshot launcher";
    "--release ${mod}+Shift+Print" = "exec flameshot full";
    "--release Alt+Shift+4" = "exec flameshot gui";

    # Global mic push-to-talk
    # "--no-repeat KP_Multiply" = "exec ${push-to-talk} on";
    # "--release KP_Multiply" = "exec ${push-to-talk} off";

    # Scratchpad
    "${mod}+Shift+grave" = "move scratchpad";
    "${hyper}+grave" = "scratchpad show";
    #for_window [instance="dropdown"] move scratchpad, border pixel 2, resize set 80 ppt 50 ppt, move absolute position 300 0
    "${mod}+grave" = ''exec --no-startup-id i3-scratchpad "dropdown"'';

    # start a terminal
    "${mod}+Return" = "exec ${term}";
    "${mod}+Shift+Return" =
      ''exec ${term} --working-directory "$(${windowcwd})"'';

    # Workspaces
    "${mod}+Mod1+Right" = "workspace next";
    "${mod}+Mod1+Left" = "workspace prev";
    "${mod}+Control+Left" = "move workspace to output left";
    "${mod}+Control+Right" = "move workspace to output right";

    "${mod}+Control+Delete" =
      "exec swaynag -t warning -m 'Quit wayland?' -b 'Yes' 'swaymsg exit'";
  };
  bars = [{
    colors.background = "#000000";
    colors.separator = "#666666";
    colors.statusline = "#dddddd";
    fonts = {
      names = [ "DejaVu Sans Mono" "FontAwesome" ];
      size = 12.0;
    };
    command = "waybar";
    # TODO: Port to native config
    # statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3/status.toml}";
  }];
  modes = {
    resize = {
      "h" = "resize shrink width 10 px or 10 ppt";
      "j" = "resize grow height 10 px or 10 ppt";
      "k" = "resize shrink height 10 px or 10 ppt";
      "l" = "resize grow width 10 px or 10 ppt";
      "${mod}+h" = "resize shrink width 5 px or 5 ppt";
      "${mod}+j" = "resize grow height 5 px or 5 ppt";
      "${mod}+k" = "resize shrink height 5 px or 5 ppt";
      "${mod}+l" = "resize grow width 5 px or 5 ppt";
      "Escape" = "mode default";
      "Return" = "mode default";
      "${mod}+r" = "mode default";

      # Picture-in-picture helpers
      "${mod}+s" = "sticky toggle, mode default";
      "${mod}+p" =
        "resize set 30 ppt 40 ppt, move absolute position 1800 0, mode default, sticky toggle";
      "${mod}+m" =
        "resize set 80 ppt 50 ppt, move absolute position 300 0, mode default";
    };
    nag = {
      "Escape" = "exec swaynagmode --exit";
      "Return" = "exec swaynagmode --confirm";
      "Left" = "exec swaynagmode --select next";
      "Right" = "exec swaynagmode --select prev";
    };
  };
  window.commands = [
    {
      criteria = { app_id = "dropdown"; };
      command = "move scratchpad";
    }
    {
      criteria = { title = "pavucontrol"; };
      command = "floating enable";
    }
    {
      criteria = { window_type = "dialog"; };
      command = "floating enable";
    }
    {
      criteria = { window_role = "dialog"; };
      command = "floating enable";
    }
  ];
}
