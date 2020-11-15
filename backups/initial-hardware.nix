# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7d4ceaaa-2cd6-49c5-a60e-6f5cc8f87f93";
      fsType = "btrfs";
      options = [ "subvol=@rootnix" ];
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/fc62b9c4-4852-421c-af43-0fbb9b577fe2";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7d4ceaaa-2cd6-49c5-a60e-6f5cc8f87f93";
      fsType = "btrfs";
      options = [ "subvol=@boot" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/7d4ceaaa-2cd6-49c5-a60e-6f5cc8f87f93";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/A061-2C06";
      fsType = "vfat";
    };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
