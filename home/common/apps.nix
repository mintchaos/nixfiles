{ pkgs, ... }:

{
   home.packages = with pkgs; [
    # Apps
    google-chrome
    firefox-beta-bin
    discord
    # steam
    lutris-unwrapped
    vscode
    slack

    pulsemixer
    playerctl
    qalculate-gtk

    ulauncher
    # rofi things
    rofi-calc
    rofimoji
    surfraw

    # PDF, image mainpulation
    flameshot
    xournalpp
    ghostscript
    gimp
    krita
    qpdf
    xournal
    zathura
    colorpicker
    fontpreview
    #skanlite
    #simple-scan

    obs-studio # Screen recording, stremaing
    transmission-gtk # Torrents

    #mplayer  # TODO: Switch to mpc?
    vlc
  ];
}
