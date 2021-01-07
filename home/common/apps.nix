{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  programs.git.delta.enable = true;
  programs.termite = {
    enable = true;
    backgroundColor = "#262335";
  };
  programs.alacritty = {
    enable = true;
    settings = {
      window.padding = {
        x = 5;
        y = 5;
      };
      colors.primary.background = "#241B2F";
      background_opacity = 0.95;
      cursor = {
        style = "Beam";
        vi_mode_style = "Block";
      };
    };
  };

  home.file.".tmux.conf".source = ../config/tmux.conf;

  # Run `gpg-connect-agent reloadagent /bye` after changing to reload config
  # home.file.".gnupg/gpg-agent.conf".text = ''
  #   pinentry-program ${pkgs.pinentry}/bin/pinentry
  # '';

  home.packages = with pkgs; [
    # Apps
    i3status-rust
    google-chrome-beta
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
    okular
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

    # Progamming
    ctags
    curlie
    python3
    python37Packages.ipython
    python37Packages.pynvim
    gcc
    go
    nodejs-10_x
    websocat # websocket netcat
    # zeal # offline docs
    docker
    docker-compose
    google-cloud-sdk

    # Programming: Rust
    #latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    #rustracer
    #cargo-edit

    drive # google drive cli
    obs-studio # Screen recording, stremaing
    transmission-gtk # Torrents

    #mplayer  # TODO: Switch to mpc?
    vlc

    srandrd # Daemon for detecting hotplug display changes, calls autorandr

    # TODO: Move these to system config?
    maim
    bat
    mdcat
    #delta
    file
    fzf
    gotop
    jq
    powerstat
    lsof
    #tlp
    hsetroot # for setting bg in picom (xsetroot doesn't work)
    xrandr-invert-colors
    xcwd # cwd of the current x window, tiny C program
    xorg.xdpyinfo
    xorg.xev
    xorg.xkill
    pasystray
    whois

    wally-cli

    # Needed for GTK
    gnome3.dconf
  ];
}
