{ config, pkgs, lib, ... }:

{
  imports = [ ./desktop.nix ];

  services.xserver = {
    enable = true;
    layout = "us";
    libinput.enable = true;
    xkbOptions = "compose:ralt";
    windowManager.i3.enable = true;
    windowManager.i3.package = pkgs.i3-gaps;
    # displayManager.startx.enable = true;
    displayManager.defaultSession = "none+i3"; # We startx in our home.nix
    gdk-pixbuf.modulePackages =
      [ pkgs.librsvg ]; # this exists so GTK programs can read SVGs.
  };

  programs.xss-lock.enable = true;

  environment.systemPackages = with pkgs; [
    clipmenu
    clipnotify
    i3status-rust
    networkmanagerapplet
    pcmanfm
    xclip
    xdotool
    xsel
  ];

  systemd.sleep.extraConfig = "HibernateMode=reboot";

  #services.clipmenu.enable = true;
  # Based on https://github.com/cdown/clipmenu/blob/develop/init/clipmenud.service
  systemd.user.services.clipmenud = {
    enable = true;
    description = "Clipmenu daemon";
    serviceConfig = {
      Type = "simple";
      NoNewPrivileges = true;
      ProtectControlGroups = true;
      ProtectKernelTunables = true;
      RestrictRealtime = true;
      MemoryDenyWriteExecute = true;
    };
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    environment = {
      DISPLAY = ":0";
      CM_OUTPUT_CLIP = "true";
    };
    path = [ pkgs.clipmenu ];
    script = ''
      ${pkgs.clipmenu}/bin/clipmenud
    '';
  };
}
