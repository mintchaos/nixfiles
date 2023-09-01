{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  programs.git.delta.enable = true;

  programs.alacritty = {
    enable = true;
    # settings = {
    #   window.padding = {
    #     x = 5;
    #     y = 5;
    #   };
    #   colors.primary.background = "#241B2F";
    #   background_opacity = 0.95;
    #   cursor = {
    #     style = "Beam";
    #     vi_mode_style = "Block";
    #   };
    # };
  };

  home.file.".tmux.conf".source = ../config/tmux.conf;

  # Run `gpg-connect-agent reloadagent /bye` after changing to reload config
  # home.file.".gnupg/gpg-agent.conf".text = ''
  #   pinentry-program ${pkgs.pinentry}/bin/pinentry
  # '';

  home.packages = with pkgs; [
    # env/shell
    fishPlugins.foreign-env

    # fonts
    fira-code
    ibm-plex
    cascadia-code

    # Progamming
    ctags
    curlie
    python3
    gcc
    go
    nodejs-18_x
    websocat # websocket netcat
    # zeal # offline docs

    # Programming: Rust
    #latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    #rustracer
    #cargo-edit

    drive # google drive cli

    # TODO: Move these to system config?
    # maim
    nnn
    exa
    bat
    mdcat
    #delta
    file
    fzf
    # gotop
    jq
    # powerstat
    lsof

    # Desktop environment agnostic packages.
    fd
    git
    gitAndTools.gh
    gnumake
    htop
    inetutils
    neovim
    patchelf
    pciutils
    ripgrep
    tmux
    tree
    unzip
    wget
    nixfmt
    nnn

  ];
}
