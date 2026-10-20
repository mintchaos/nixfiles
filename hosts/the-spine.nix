{
  config,
  pkgs,
  lib,
  inputs,
  nixpkgs-unstable,
  ...
}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Show the LUKS password prompt in Plymouth before mounting the root volume.
  boot.initrd.systemd.enable = true;
  boot.plymouth = {
    enable = true;
    theme = "mintchaos";
    themePackages = [
      (pkgs.runCommand "plymouth-theme-mintchaos"
        {
          nativeBuildInputs = [
            pkgs.imagemagick
            pkgs.librsvg
          ];
        }
        ''
          themeDir="$out/share/plymouth/themes/mintchaos"
          mkdir -p "$themeDir"
          cp ${../themes/mintchaos/mintchaos.plymouth} "$themeDir/mintchaos.plymouth"
          cp ${config.boot.plymouth.package}/share/plymouth/themes/spinner/*.png "$themeDir/"

          # Two-step draws the header immediately above the spinner. Transparent
          # space below the artwork leaves it just below the midpoint at 1440p.
          rsvg-convert -w 246 -h 293 ${../themes/mintchaos/min-tch-aos.svg} -o "$TMPDIR/mintchaos-logo.png"
          magick "$TMPDIR/mintchaos-logo.png" -gravity north -background none \
            -extent 246x597 "$themeDir/header-image.png"

          # The website's panel brown is the ring; its logo brown is the pointer.
          magick -size 256x1 xc:'#2D231A' -fill '#3B2617' \
            -draw 'rectangle 192,0 255,0' "$TMPDIR/spinner-colors.png"
          for frame in "$themeDir"/{animation,throbber}-*.png; do
            magick "$frame" "$TMPDIR/spinner-colors.png" -channel RGB -clut +channel \
              -channel A -evaluate Multiply 4 +channel -strip "PNG32:$frame.new"
            mv "$frame.new" "$frame"
          done

          magick ${config.boot.plymouth.logo} -channel RGB -fill '#3B2617' \
            -colorize 100 +channel "$themeDir/watermark.png"
        ''
      )
    ];
  };
  # Keep kernel and initrd status text off the console until Plymouth appears.
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
  ];

  # Delete once https://github.com/NixOS/nixpkgs/pull/107400 is in.

  # xone 0.5.8 fixes the wireless dongle losing its controller after sleep.
  boot.kernelPackages = pkgs.linuxPackages_latest.extend (
    _: prev: {
      xone = prev.xone.overrideAttrs (_: {
        version = "0.5.8";
        src = pkgs.fetchFromGitHub {
          owner = "dlundqvist";
          repo = "xone";
          tag = "v0.5.8";
          hash = "sha256-ENk/SOUzXbzXYhwN3AdbO2u/tWjf/Mn+V22A2ce21XU=";
        };
      });
    }
  );
  boot.blacklistedKernelModules = [
    "mei_me"
    "radeon"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = [ ];

  networking.hostName = "the-spine";
  # DNS is handled by the local dnsmasq and resolvconf setup.
  # Avoid blocking NetworkManager's wake path on resolvconf updates.
  networking.networkmanager.dns = "none";
  # openresolv's default wrapper hides the helpers its dnsmasq subscriber
  # needs to send changing Tailscale DNS routes over D-Bus.
  networking.resolvconf.package = pkgs.openresolv.overrideAttrs (_: {
    postInstall = ''
      wrapProgram "$out/sbin/resolvconf" --set PATH "${
        lib.makeBinPath [
          pkgs.coreutils
          pkgs.dbus
          pkgs.gnugrep
        ]
      }"
    '';
  });
  services.dnsmasq.enable = true;
  # Reapply routes held by resolvconf after dnsmasq loses its D-Bus state.
  systemd.services.dnsmasq.serviceConfig.ExecStartPost =
    "${lib.getExe config.networking.resolvconf.package} -u";
  systemd.services.tailscaled.after = [ "dnsmasq.service" ];
  systemd.services.tailscaled.wants = [ "dnsmasq.service" ];
  services.dnsmasq.settings.server = [
    "100.100.100.100"
    "8.8.8.8"
    "1.1.1.1"
    # "2001:4860:4860::8844"
  ];

  # Tailscale VPN
  services.tailscale.enable = true;
  services.udisks2.enable = true;

  services.localtimed.enable = true;

  # ssh
  services.sshd.enable = true;
  programs.fish.enable = true;

  nix.settings.trusted-users = [
    "root"
    "xian"
  ];
  users.users.xian = {
    isNormalUser = true;
    home = "/home/xian";
    description = "xian";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "docker"
      "sudoers"
      "audio"
      "video"
      "disk"
      "networkmanager"
      "onepassword"
    ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaFTyWYnGdx6cUNXVOrBUQcjzfs6JhE0kqtGNW16comvc+oED1qDEBy3Q2rKhh+gXwtiwjpZyf+8ELbQ1rAAG5rapBLk8eyESfZvpqFZLBTmt8rB7IVc85byoRgjIiS6x6h3n8fefFMOUoft832u3CGidQ+50qLVqdIquyeWu+77uvIWCGyXHgOe5ufN9hf1CUA8ZCsJqmRDFgbXjJCRkcPXEXd/605eUkGh8KhV4Y6Zjj8JkC/VcJsaI3x6b626ZUmzn56Sn+rOqo1zOdXzyvz54Q+EydO/CyEVpW7G4YjL32d6XQtaB35qkdU8nHX1U7L4L6E3pKGJtMcTlV56NV xian@Brain-Problem-Situation.local"
    ];
    # hashedPassword = let hashedPassword = import ./.hashedPassword.nix; in hashedPassword; # Make with mkpasswd
  };

  environment.systemPackages = with pkgs; [
    home-manager

    # Desktop
    alsa-tools
    arandr
    colord
    dunst
    feh
    libnotify
    maim
    openvpn
    pavucontrol

    # Apps
    gnupg
  ];

  services.displayManager.autoLogin = {
    enable = true;
    user = "xian";
  };

  hardware.steam-hardware.enable = true; # VR
  hardware.xone.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
  services.lact.enable = true;
  services.input-remapper.enable = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Started on-demand by docker.socket
  };

  # Firewall bits
  # 24800 is for barrier
  # Steam LAN transfer: TCP 27040 (transfer), UDP 27031-27036 (discovery)
  networking.firewall.allowedTCPPorts = [
    24800
    27040
  ];
  networking.firewall.allowedUDPPorts = [
    24800
    27031
    27032
    27033
    27034
    27035
    27036
  ];
  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  services.openssh = {
    enable = true;
    startWhenNeeded = true; # Don't start until socket request comes in to systemd
    settings = {
      PasswordAuthentication = false;
    };
    settings.KbdInteractiveAuthentication = false;
  };

  console.font = lib.mkForce "${pkgs.terminus_font}/share/consolefonts/ter-u16n.psf.gz";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # When sleep is triggered via systemd's Sleep() DBus method (used by vicinae's
  # "Sleep" power menu option), it first suspends to RAM. If the system stays
  # suspended for this duration, it will wake and hibernate to disk instead.
  # The default (when unset) is 2 hours.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "6h";
  };
  # high-resolution display

  system.stateVersion = "20.09"; # Did you read the comment?

  programs._1password = {
    enable = true;
    package = nixpkgs-unstable._1password-cli;
  };

  programs._1password-gui = {
    enable = true;
    package = nixpkgs-unstable._1password-gui;
    polkitPolicyOwners = [ "xian" ];
  };

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ".zen-wrapped";
      mode = "0755";
    };
  };
}
