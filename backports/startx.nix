# https://github.com/nixos/nixpkgs/blob/master/nixos/modules/services/x11/display-managers/startx.nix
{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.xserver.displayManager.startx;

in

{

  ###### interface

  options = {
    services.xserver.displayManager.startx = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable the dummy "startx" pseudo-display manager,
          which allows users to start X manually via the "startx" command
          from a vt shell. The X server runs under the user's id, not as root.
          The user must provide a ~/.xinintrc file containing session startup
          commands, see startx(1). This is not autmatically generated
          from the desktopManager and windowManager settings.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {
    services.xserver = {
      exportConfiguration = true;
      displayManager.job.execCmd = "";
      displayManager.lightdm.enable = lib.mkForce false;
    };
    systemd.services.display-manager.enable = false;
    environment.systemPackages =  with pkgs; [ xorg.xinit ];
  };

}
