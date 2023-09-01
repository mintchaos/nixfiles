{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  manual.manpages.enable = false;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "christian.metts";
  home.homeDirectory = "/Users/christian.metts";

  imports = [ ./common/common.nix ];
  programs.fish = {
    enable = true;
    shellAliases = { ls = "nnn"; };
    shellInit = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # work stuff
    kubectl
    yarn
    tmux
    # (jdk8.overrideAttrs (_: { postPatch = "rm man; ln -s ../zulu-8.jdk/Contents/Home/man man"; }))
    kubernetes-helm
    maven
    awscli2
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";
}
