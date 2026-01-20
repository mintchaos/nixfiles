# Wayland alternative to x11.nix
# TODO: Add https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit
{
  pkgs,
  config,
  lib,
  ...
}:
let
  sessionVars = {
    # For my fancy bookmark script: home/bin/bookmark
    BOOKMARK_DIR = "${config.home.homeDirectory}/remote/bookmarks";

    # Sway/Wayland env
    # (Should this be in wayland.windowManager.sway.config.extraSessionCommands?)
    GDK_BACKEND = "wayland"; # GTK
    XDG_SESSION_TYPE = "wayland"; # Electron
    # Removed: SDL_VIDEODRIVER = "wayland"; # SDL
    # ^ This breaks some games, maybe proton related? - https://www.reddit.com/r/linux_gaming/comments/17lbqdv/baldurs_gate_iii_sound_but_no_display/
    QT_QPA_PLATFORM = "wayland"; # QT
    XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache/";
    GDK_PIXBUF_MODULE_FILE = "$(ls ${pkgs.librsvg.out}/lib/gdk-pixbuf-*/*/loaders.cache)"; # SVG GTK icons fix? Not sure

    # Electron apps should use Ozone/wayland
    NIXOS_OZONE_WL = "1";
    USE_WAYLAND_GRIM = "1";
  };

  lockcmd = "${pkgs.swaylock}/bin/swaylock -fF";

  waybarCommon = {
    layer = "top";
    position = "bottom";
    height = 30;
    modules-center = [ "mpris" ];
    modules-right = [
      "pulseaudio/slider"
      "idle_inhibitor"
      "temperature"
      "cpu"
      "clock"
      "tray"
    ];

    mpris = {
      format = "{player_icon} {status_icon} {dynamic}";
      player-icons = {
        "default" = "▶";
        "cider" = "🎵";
      };
      status-icons = {
        "paused" = "⏸";
      };
    };

    cpu = {
      format = "{icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}";
      format-icons = [
        "<span color='#69ff94'>▁</span>" # green
        "<span color='#2aa9ff'>▂</span>" # blue
        "<span color='#f8f8f2'>▃</span>" # white
        "<span color='#f8f8f2'>▄</span>" # white
        "<span color='#ffffa5'>▅</span>" # yellow
        "<span color='#ffffa5'>▆</span>" # yellow
        "<span color='#ff9977'>▇</span>" # orange
        "<span color='#dd532e'>█</span>" # red
      ];
    };

    clock = {
      format = "{:%I:%M}";
      format-alt = "{:%A, %B %d, %Y (%R)}";
      tooltip-format = "<tt><small>{calendar}</small></tt>";
      calendar = {
        mode = "year";
        mode-mon-col = 3;
        weeks-pos = "right";
        on-scroll = 1;
        format = {
          months = "<span color='#ffead3'><b>{}</b></span>";
          days = "<span color='#ecc6d9'><b>{}</b></span>";
          # weeks = "<span color='#99ffdd'><b>W{}</b></span>";
          weeks = "";
          weekdays = "<span color='#dddddd'><b>{}</b></span>";
          today = "<span color='#ffffff'><b><u>{}</u></b></span>";
        };
      };
      actions = {
        on-click-right = "mode";
        # on-scroll-up = "tz_up";
        # on-scroll-down = "tz_down";
        on-scroll-up = "shift_up";
        on-scroll-down = "shift_down";
      };
    };

    tray = {
      spacing = 10;
    };

    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
    };
  };

in
{
  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
  };

  home.sessionVariables = sessionVars;

  home.packages = with pkgs; [
    wdisplays
    wl-mirror

    # Not sure if these are needed but having trouble with some tray icons not
    # showing up, so let's see if it helps.
    networkmanagerapplet
    hicolor-icon-theme
    gnome-icon-theme
    pamixer
    redshift
    sway-audio-idle-inhibit
    swaybg
    grim
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
  };

  home.enableNixpkgsReleaseCheck = false;

  services.gammastep = {
    enable = true;
    tray = true; # Broken?
    provider = "geoclue2";
    temperature.day = 5700;
    temperature.night = 3500;
  };

  programs.rofi = {
    enable = true;
    font = "DejaVu Sans Mono 12";
    theme = "Monokai";
    package = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };
    extraConfig = {
      combi-mode = "window,drun,calc";
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      font-size = 24;
      indicator-idle-visible = true;
      indicator-radius = 150;
      show-failed-attempts = true;
    };
  };

  programs.waybar = {
    enable = true;
    style = ../config/waybar.css;
    settings = {
      mainbar = waybarCommon // {
        modules-left = [
        "niri/workspaces"
        "niri/window"
          # "sway/workspaces"
          # "sway/mode"
          # "sway/window"
        ];
      };
    };
  };

  # The home-assistant services below won't work unless we're also using
  # home-manager's sway module.

  services.mako.enable = true;
  services.mako.settings.default-timeout = 3000;
  services.cliphist.enable = true;
  services.network-manager-applet.enable = true;

  services.swayidle = {
    enable = true;
    events = {
      "before-sleep" = lockcmd;
      "lock" = lockcmd;
    };
    timeouts = [
      # Turn off screen (just before locking)
      {
        timeout = 300;
        command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
        resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
      }
      # Lock computer
      {
        timeout = 330;
        command = lockcmd;
      }
      # suspend
      {
        timeout = 600;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };

  # Not working? Need to try the stable version
  #services.swayosd.enable = true;

  wayland.windowManager.sway.swaynag.enable = true;

  # Note: We can also use program.sway but home-manager integrates systemd
  # graphical target units properly so that swayidle and friends all load
  # correctly together. It also handles injecting the correct XDG_* variables.
  wayland.windowManager.sway = {
    enable = true;
    config = import ../config/sway.nix { inherit pkgs lib lockcmd; };
    extraOptions = [ "-Dlegacy-wl-drm" ];
  };

}
