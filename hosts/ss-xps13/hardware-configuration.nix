# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1a6c2a7c-fce9-41c8-9222-b1f2c402d697";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  boot.initrd.luks.devices."nixcrypt".device =
    "/dev/disk/by-uuid/79c73be1-fbb1-49aa-969b-86232eadc1a2";

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/1a6c2a7c-fce9-41c8-9222-b1f2c402d697";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/1a6c2a7c-fce9-41c8-9222-b1f2c402d697";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/1a6c2a7c-fce9-41c8-9222-b1f2c402d697";
    fsType = "btrfs";
    options = [ "subvol=var" ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/1a6c2a7c-fce9-41c8-9222-b1f2c402d697";
    fsType = "btrfs";
    options = [ "subvol=snapshots" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EE1D-4F00";
    fsType = "vfat";
  };

  fileSystems."/.btrfs-root" = {
    device = "/dev/disk/by-uuid/1a6c2a7c-fce9-41c8-9222-b1f2c402d697";
    fsType = "btrfs";
  };

  swapDevices = [
    {
      device = "/var/swap";
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
