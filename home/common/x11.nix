{ pkgs, ... }:

{
  # This setup for console-based login and automatic startx works with:
  #   services.xserver.displayManager.startx.enable = true;
  #   services.xserver.desktopManager.default = "none";

  # TODO: exec xcalib -d :0 "${nixpkgs}/hardware/thinkpad-x1c-hdr.icm"
  home.file.".xinitrc".text = ''
    # Delegate to xsession config
    . ~/.xsession
  '';

  gtk = {
    enable = true;
    theme = {
      package = pkgs.theme-vertex;
      name = "Vertex-Dark";
    };
    iconTheme = {
      package = pkgs.tango-icon-theme;
      name = "Tango";
    };
    gtk3.extraCss = builtins.readFile (./. + "/../config/gtk3/gtk.css");
  };

  xsession = {
    enable = true;
    windowManager.command = "i3";

    # dbus-launch manages cross-process communication (required for GTK systray icons, etc).
    # FIXME: Is dbus-launch necessary now that it's part of xsession?
    # windowManager.command = "dbus-launch --exit-with-x11 i3";

    pointerCursor = {
      name = "Vanilla-DMZ-AA";
      package = pkgs.vanilla-dmz;
      size = 32;
    };
  };

  # Trying on a compisitor (optional) mainly to reduce tearing and possibly fix
  # DRI3 freezing on intel
  services.picom = {
    enable = true;
    experimentalBackends = true;
    backend = "glx";
    vSync = true;
    extraOptions = ''
      glx-no-stencil = true;
      glx-no-rebindpixmap = true;
      # noUseDamage = true;
      xrender-sync-fence = true;
    '';
  };

  services.network-manager-applet.enable = true;

  services.redshift = {
    enable = true;
    provider = "geoclue2";
    #provider = "manual";
    #latitude = "43.65";
    #longitude = "-79.38";
    temperature.day = 5700;
    temperature.night = 3500;
    # brightness.day = "1.0";
    # brightness.night = "0.95";
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        geometry = "600x5-30+20";
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        font = "DejaVu Sans Mono 10";
        format = ''
          <b>%s</b>
          %b'';
        icon_position = "left";
        max_icon_size = 48;
        indicate_hidden = "yes";
        shrink = "no";
        frame_color = "#aaaaaa";
        markup = "full";
        word_wrap = "yes";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";

        dmenu = "rofi -dmenu -p Dunst";
        browser = "xdg-open";
      };
      shortcuts = {
        close = "ctrl+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };
    };
  };

  programs.rofi = {
    enable = true;
    theme = "/home/xian/.config/rofi/chaos-by-design.rasi";
  };
}
