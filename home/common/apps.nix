{
  pkgs,
  inputs,
  nixpkgs-unstable,
  ...
}:
{
  imports = [inputs.zen-browser.homeModules.beta];
  
  programs.home-manager.enable = true;
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
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
  programs.rclone = {
    enable = true;
  };

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
    };

    profiles.default = {
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "zen.view.compact.hide-tabbar" = true;
        "zen.urlbar.behavior" = "float";
      };

      mods = [
        "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
        "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
      ];

      search = {
        force = true;
        default = "ddg";
      };
    };
  };
  programs.zen-browser.nativeMessagingHosts = [
    pkgs.firefoxpwa
  ];


  home.file.".tmux.conf".source = ../config/tmux.conf;

  # Run `gpg-connect-agent reloadagent /bye` after changing to reload config
  # home.file.".gnupg/gpg-agent.conf".text = ''
  #   pinentry-program ${pkgs.pinentry}/bin/pinentry
  # '';

  home.packages = with pkgs; [
    yazi
    bun
    inputs.seance.packages.${pkgs.stdenv.hostPlatform.system}.default
    (lib.lowPrio ghostty)
    nixpkgs-unstable.jujutsu
    nixpkgs-unstable.lazyjj
    warp-terminal

    # Apps
    i3status-rust
    google-chrome
    firefox
    # arc-browser // only darwin currently
    discord
    # steam
    gamescope
    lutris-unwrapped
    vscode
    nixpkgs-unstable.zed-editor
    signal-desktop
    cider-2 # apple music
    _1password-cli
    _1password-gui

    pulsemixer
    playerctl
    qalculate-gtk

    ulauncher
    # rofi things
    rofi-calc
    rofimoji
    surfraw

    # PDF, image mainpulation
    pandoc
    flameshot
    xournalpp
    ghostscript
    gimp
    krita

    # Design
    inputs.pencil-dev.packages.${pkgs.stdenv.hostPlatform.system}.pencil
    inputs.pencil-dev.packages.${pkgs.stdenv.hostPlatform.system}.pencil-gui
    qpdf
    # zathura
    fontpreview
    #skanlite
    #simple-scan

    # calculators
    clac
    nota

    # Progamming
    cargo
    lazygit
    television
    uv
    gh
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
    whois

    wally-cli

    # Needed for GTK
    # gnome3.dconf
  ];
}
