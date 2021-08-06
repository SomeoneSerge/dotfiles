# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/dcacf3bc-0a68-43b8-910a-8f92a4330aa0";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-uuid/2aa72e49-6996-468b-a813-ee00e6fb1e41";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/39CC-DF30";
      fsType = "vfat";
    };

  swapDevices = [ ];

}
