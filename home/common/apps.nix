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
      window.opacity = 0.95;
      cursor = {
        style = "Beam";
        vi_mode_style = "Block";
      };
    };
  };
  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    enableFishIntegration = true;
  };

  home.file.".tmux.conf".source = ../config/tmux.conf;

  # Run `gpg-connect-agent reloadagent /bye` after changing to reload config
  # home.file.".gnupg/gpg-agent.conf".text = ''
  #   pinentry-program ${pkgs.pinentry}/bin/pinentry
  # '';

  home.packages = with pkgs; [
    # Apps
    i3status-rust
    google-chrome
    firefox
    # arc-browser // only darwin currently
    discord
    # steam
    lutris-unwrapped
    vscode
    zed-editor
    super-productivity
    signal-desktop
    cider-2 # apple music

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
    # zathura
    fontpreview
    #skanlite
    #simple-scan

    # Progamming
    ctags
    curlie
    python3
    gcc
    go
    nodejs
    websocat # websocket netcat
    nixd
    # zeal # offline docs
    # docker
    # docker-compose
    # google-cloud-sdk

    # Programming: Rust
    #latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    #rustracer
    #cargo-edit

    drive # google drive cli
    obs-studio # Screen recording, stremaing
    transmission_4-gtk # Torrents

    #mplayer  # TODO: Switch to mpc?
    vlc

    srandrd # Daemon for detecting hotplug display changes, calls autorandr

    # TODO: Move these to system config?
    maim
    eza
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
    # gnome3.dconf
  ];
}
