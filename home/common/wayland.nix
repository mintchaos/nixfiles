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
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    # Explicitly null to opt into new home-manager GTK module behavior:
    # GTK4 settings are managed separately, not inherited from gtk3.
    gtk4.theme = null;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  home.enableNixpkgsReleaseCheck = false;

  services.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };
  };

  services.gammastep = {
    enable = true;
    tray = true; # Broken?
    provider = "geoclue2";
    temperature.day = 5700;
    temperature.night = 3500;
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


  # The home-assistant services below won't work unless we're also using
  # home-manager's sway module.

  services.mako.enable = true;
  services.mako.settings.default-timeout = 3000;
  services.cliphist.enable = true;
  services.network-manager-applet.enable = true;

  services.playerctld.enable = true;

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    settings = {
      program_options = {
        file_manager = "${pkgs.yazi}/bin/yazi";
      };
    };
  };

  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = lockcmd;
      }
      {
        event = "lock";
        command = lockcmd;
      }
    ];
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
