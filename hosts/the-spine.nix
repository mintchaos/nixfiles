{ config, pkgs, lib, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.blacklistedKernelModules = [ "mei_me" "radeon" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = [ ];

  networking.hostName = "the-spine";
  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "1.1.1.1" "8.8.8.8" "2001:4860:4860::8844" ];

  services.localtime.enable = true;

  # ssh
  services.sshd.enable = true;
  programs.fish.enable = true;

  users.users.xian = {
    isNormalUser = true;
    home = "/home/xian";
    description = "xian";
    shell = pkgs.fish;
    extraGroups =
      [ "wheel" "docker" "sudoers" "audio" "video" "disk" "networkmanager" ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaFTyWYnGdx6cUNXVOrBUQcjzfs6JhE0kqtGNW16comvc+oED1qDEBy3Q2rKhh+gXwtiwjpZyf+8ELbQ1rAAG5rapBLk8eyESfZvpqFZLBTmt8rB7IVc85byoRgjIiS6x6h3n8fefFMOUoft832u3CGidQ+50qLVqdIquyeWu+77uvIWCGyXHgOe5ufN9hf1CUA8ZCsJqmRDFgbXjJCRkcPXEXd/605eUkGh8KhV4Y6Zjj8JkC/VcJsaI3x6b626ZUmzn56Sn+rOqo1zOdXzyvz54Q+EydO/CyEVpW7G4YjL32d6XQtaB35qkdU8nHX1U7L4L6E3pKGJtMcTlV56NV xian@Brain-Problem-Situation.local"
    ];
    # hashedPassword = let hashedPassword = import ./.hashedPassword.nix; in hashedPassword; # Make with mkpasswd
  };

  imports = [ ./the-spine-hardware-configuration.nix ../common/desktop-i3.nix ];

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

  services.xserver.videoDrivers = [ "amdgpu" ];

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

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  system.stateVersion = "20.09"; # Did you read the comment?
}
