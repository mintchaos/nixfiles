{ pkgs, ... }: {
  system.copySystemConfiguration = true;
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      neovim = pkgs.neovim.override { vimAlias = true; };
      #      unstable = import <nixos-unstable> { config.allowUnfree = true; };
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
    nerdfonts # Includes font-awesome, material-icons, powerline-fonts
    emojione
    source-sans-pro
  ];

  hardware.video.hidpi.enable = false;
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

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  programs.dconf.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
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
  hardware.pulseaudio.support32Bit = true;

  hardware.opengl = {
    enable = true;
    # extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
    #    package = pkgs.unstable.mesa.drivers;
    driSupport32Bit = true;
    #    package32 = pkgs.unstable.pkgsi686Linux.mesa.drivers;
  };
  hardware.xpadneo.enable = true;
  sound.enable = true;

  users.users.localtimed.group = "localtimed";
  users.groups.localtimed = { };
}
