{ lib, config, pkgs, ... }:

{
  services.samba = {
    enable = true;
    package = pkgs.sambaFull;
  };
  services.samba-wsdd = {
    enable = true;
    workgroup = "AALTO";
    interface = "enp4s0";
  };
  krb5 = {
    enable = true;
    libdefaults.default_realm = "ORG.AALTO.FI";
  };
  # Ultimately doesn't work, but I'll keep it
  fileSystems."/work" = {
    device = "lgw02.triton.aalto.fi:/scratch/work:&";
    options = [ "x-systemd.automount" "noauto" "nfsvers=4.0" "tcp" "timeo=600" "retrans=2" "hard" "intr" "noatime" "nolock" "ac" "acregmin=30" "acregmax=60" "sec=krb5" ];
    fsType = "nfs";
  };
  networking.firewall.allowedTCPPorts = [ 5357 ];
  networking.firewall.allowedUDPPorts = [ 3702 ];
}
