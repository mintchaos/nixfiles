{ pkgs, ... }: {
  system.copySystemConfiguration = true;

  services.gnome3.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;
  programs.seahorse.enable = true;
  programs.dconf.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      neovim = pkgs.neovim.override { vimAlias = true; };
    };
  };

  # Desktop environment agnostic packages.
  environment.systemPackages = with pkgs; [
    acpi
    bind # nslookup etc
    binutils-unwrapped
    dmidecode
    fd
    git
    gitAndTools.gh
    gnumake
    htop
    inetutils
    lm_sensors
    mkpasswd
    neovim
    patchelf
    pciutils
    powertop
    psmisc
    ripgrep
    sysstat
    tmux
    tree
    unzip
    wget
    nixfmt
    nnn
  ];

  environment.shellInit = ''
    export EDITOR=nvim
    export VISUAL=nvim
  '';

  fonts.fonts = with pkgs; [
    noto-fonts
    dejavu_fonts
    terminus
    nerdfonts # Includes font-awesome, material-icons, powerline-fonts
    emojione
    source-sans-pro
  ];

  hardware.video.hidpi.enable = true;
  i18n = { defaultLocale = "en_US.UTF-8"; };
  console.font = "ter-i32b";
  console.packages = with pkgs; [ terminus_font ];

  networking.networkmanager.enable = true;
  # networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [];

  hardware.sane.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # Need full for bluetooth support
    package = pkgs.pulseaudioFull;
    # extraModules = [ pkgs.pulseaudio-modules-bt ];
  };

  programs.light.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  # Gaming and app wrapping (Steam)
  services.flatpak.enable = true;
  services.accounts-daemon.enable = true; # Required for flatpak+xdg
  xdg.portal.enable =
    true; # xdg portal is used for tunneling permissions to flatpak
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  sound.enable = true;
}
