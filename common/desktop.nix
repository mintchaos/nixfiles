{ pkgs, ... }: {
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
    nixfmt-classic
    nnn
  ];

  environment.shellInit = ''
    export EDITOR=nvim
    export VISUAL=nvim
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  fonts.packages = with pkgs;
    [ noto-fonts dejavu_fonts emojione source-sans-pro ]
    ++ builtins.filter lib.attrsets.isDerivation
    (builtins.attrValues pkgs.nerd-fonts);

  i18n = { defaultLocale = "en_US.UTF-8"; };
  console.font = "ter-i32b";
  console.packages = with pkgs; [ terminus_font ];

  networking.networkmanager.enable = true;
  # networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [];

  hardware.sane.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.rocmPackages.clr.icd
      # Encoding/decoding acceleration
      pkgs.libvdpau-va-gl
      pkgs.vaapiVdpau
    ];
  };

  services.gnome.gnome-keyring.enable = true;
  services.geoclue2.enable = true;
  programs.seahorse.enable = true;
  programs.dconf.enable = true;
  security.pam.services = {
    login.enableGnomeKeyring = true;
    gdm.enableGnomeKeyring = true;
    lightdm.enableGnomeKeyring = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.steam.enable = true;
  # /var/cache library

  programs.light.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  # Gaming and app wrapping (Steam)
  services.flatpak.enable = true;
  services.accounts-daemon.enable = true; # Required for flatpak+xdg

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # Not sure if Steam still needs this
    pulse.enable =
      true; # Pulse server emulation, useful for running pulseaudio GUIs
  };

  # hardware.opengl = {
  #   enable = true;
  #   # extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
  #   #    package = pkgs.unstable.mesa.drivers;
  #   driSupport32Bit = true;
  #   #    package32 = pkgs.unstable.pkgsi686Linux.mesa.drivers;
  # };
  hardware.xpadneo.enable = true;

  users.users.localtimed.group = "localtimed";
  users.groups.localtimed = { };
}
