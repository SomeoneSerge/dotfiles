{ config, pkgs, lib, ... }:

with lib;

{
  boot.kernelPackages = mkDefault pkgs.linuxPackages_hardened;
  security.forcePageTableIsolation = mkDefault true;
  security.lockKernelModules = mkDefault true;
  boot.kernelParams = [
    # Slab/slub sanity checks, redzoning, and poisoning
    "slub_debug=FZP"

    # Overwrite free'd memory
    "page_poison=1"

    # Enable page allocator randomization
    "page_alloc.shuffle=1"
  ];

  boot.kernel.sysctl = { };
}
