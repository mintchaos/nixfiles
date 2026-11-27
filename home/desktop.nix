{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  rexRune = inputs.rex-rune.packages.${pkgs.stdenv.hostPlatform.system}.default;
  xdgOpen = lib.getExe' pkgs.xdg-utils "xdg-open";
  niri = lib.getExe' config.programs.niri.package "niri";

  # Niri gives spawned commands an activation token so an open browser can take focus.
  rexRuneOpener = pkgs.writeShellScriptBin "xdg-open" ''
    if [[ -n "''${NIRI_SOCKET:-}" && $# -eq 1 && ( ''${1,,} == http://* || ''${1,,} == https://* ) ]] &&
       ${niri} msg action spawn -- ${xdgOpen} "$1" >/dev/null 2>&1; then
      exit 0
    fi
    exec ${xdgOpen} "$@"
  '';

  rexRuneWithNiri = pkgs.symlinkJoin {
    name = "rex-rune-with-niri";
    paths = [ rexRune ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/rex-rune" "$out/bin/rex-linux"
      makeWrapper ${lib.getExe rexRune} "$out/bin/rex-rune" \
        --prefix PATH : ${lib.makeBinPath [ rexRuneOpener ]}
      ln -s rex-rune "$out/bin/rex-linux"

      # The upstream launcher points directly to its binary, including in TryExec.
      desktopFile=share/applications/dev.shuv.rex-rune.desktop
      rm "$out/$desktopFile"
      substitute "${rexRune}/$desktopFile" "$out/$desktopFile" \
        --replace-fail "${lib.getExe rexRune}" "$out/bin/rex-rune"
    '';
  };
in
{
  home.username = "xian";
  home.homeDirectory = "/home/xian";
  home.stateVersion = "24.05";

  imports = [
    # NOTE: inputs.niri.homeModules.niri is NOT imported here because
    # inputs.niri.nixosModules.niri (imported via desktop-niri.nix) already
    # pushes it via home-manager.sharedModules for the NixOS build path.
    # The standalone home-manager path adds it in flake.nix.
    inputs.vicinae.homeManagerModules.default
    inputs.rex.homeManagerModules.default
    ./common/wayland.nix
    ./common/apps.nix
    ./common/niri
  ];

  services.rex.enable = true;
  # Leave SSH client configuration outside Home Manager for the local setup.
  programs.rex.sshGuard = false;

  home.packages = [ rexRuneWithNiri ];

  xresources.properties = {
    # Doesn't seem like most things need this, but flatpak electron apps do.
  };

}
