{ lib, config, pkgs, ... }:

{
  services.samba = {
    enable = true;
    package = pkgs.sambaFull;
  };
  networking.firewall.allowedTCPPorts = [ 5357 ];
  networking.firewall.allowedUDPPorts = [ 3702 ];
}
