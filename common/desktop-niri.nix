{ pkgs, inputs, ... }: {
  imports = [ ./desktop.nix ];

  # There's something here about binary cache that isn't working for me
  #
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-stable;
  environment.variables = {
    XDG_SESSION_DESKTOP = "niri";
    XDG_CURRENT_DESKTOP = "niri";
    # Electron apps should use Ozone/wayland
    NIXOS_OZONE_WL = "1";
    USE_WAYLAND_GRIM = "0";
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };


  environment.systemPackages = with pkgs; [
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    qt5.qtwayland # for qt
    fuzzel
    cage
    wtype # xdotool, but for wayland
    xwayland
    # kdePackages.xwaylandvideobridge # Portal for screen sharing
    xwayland-satellite-unstable
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-wlr # Backend for wayland roots
    ];
    config = {
      common = { default = [ "gtk" ]; };
      niri = {
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
    };
  };

  security.pam.services.swaylock = { };
}
