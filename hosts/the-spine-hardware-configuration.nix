# Copied from and modified the generated hardware configuration file from nixos
# install.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "btrfs" "ntfs" ];

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@rootnix" ];
  };

  boot.initrd.luks.devices."cryptroot".device =
    "/dev/disk/by-uuid/4a4689b7-bd5b-4043-aaba-01103678d815";
  boot.initrd.luks.devices."cryptswap".device =
    "/dev/disk/by-uuid/e354854b-6e4c-450c-9f74-618aede8c5f6";

  fileSystems."/boot" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@boot" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/B733-1898";
    fsType = "vfat";
  };

  # fileSystems."/mnt/the-spine-windows" = {
  #   device = "/dev/device/nvme1n1p2";
  #   fsType = "ntfs";
  #   options = [ "rw" "uid=1000" ];
  # };

  swapDevices = [{ device = "/dev/mapper/cryptswap"; }];

  # high-resolution display
  # hardware.video.hidpi.enable = lib.mkDefault true;
}
