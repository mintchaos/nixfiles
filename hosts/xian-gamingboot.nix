{ config, pkgs, lib, ... }:

{
  boot.blacklistedKernelModules = [ "mei_me" ];
  networking.hostName = "become-a-robot";
  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "1.1.1.1" "8.8.8.8" "2001:4860:4860::8844" ];
  hardware.nvidia.modesetting.enable = true;

  services.localtime.enable = true;
  # time.timeZone = "America/Los_Angeles";

  users.users.xian = {
    isNormalUser = true;
    home = "/home/xian";
    description = "me!";
    extraGroups =
      [ "wheel" "docker" "sudoers" "audio" "video" "disk" "networkmanager" ];
    uid = 1000;
    # hashedPassword = let hashedPassword = import ./.hashedPassword.nix; in hashedPassword; # Make with mkpasswd
  };

  imports = [ ../common/boot.nix ../common/desktop-i3.nix ];

  environment.systemPackages = with pkgs; [
    home-manager

    # Desktop
    alsaTools
    arandr
    colord
    dunst
    feh
    libnotify
    maim
    openvpn
    pavucontrol
    xclip
    xdotool
    xsel

    # Apps
    gnupg
  ];

  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "xian";

  hardware.steam-hardware.enable = true; # VR

  services.xserver.videoDrivers = [ "nvidia" ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Started on-demand by docker.socket
  };

  # Firewall bits
  # 24800 is for barrier
  networking.firewall.allowedTCPPorts = [ 24800 ];
  networking.firewall.allowedUDPPorts = [ 24800 ];
  services.openssh = {
    enable = true;
    startWhenNeeded =
      true; # Don't start until socket request comes in to systemd
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  console.font =
    lib.mkForce "${pkgs.terminus_font}/share/consolefonts/ter-u16n.psf.gz";

  # from the hardware scan
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  system.stateVersion = "20.09"; # Did you read the comment?
}
