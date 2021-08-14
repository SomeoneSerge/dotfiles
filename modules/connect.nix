{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.some.mesh;
  lite21 = "5.2.76.123";
  ports = {
    cjd = 43211;
    ygg = 43212;
  };
  portss = mapAttrs (key: value: toString value) ports;
in
{
  options = {
    some.mesh.enable = mkEnableOption
      "Connect to CJDNS and Yggdrasil thourgh the default server";
  };
  config = mkIf cfg.enable {
    services.cjdns = mkDefault {
      enable = true;
      UDPInterface = {
        bind = "0.0.0.0:${portss.cjd}";
        connectTo = {
          "${lite21}:${portss.cjd}" = {
            password =
              "luDcKSyS0SpvLx3nSkTFAwMjL6JSpG7ZwzbfEcALYB2ceFSBiBNJJ0AfCY9yjPSq";
            hostname = "${config.networking.fqdn}";
            publicKey =
              "ld0wgbr2wr4ku7vfnhg16py5bpnpkjd0cmn046l51g4gsxvzllg0.k";
          };
        };
      };
    };

    services.yggdrasil = {
      enable = mkDefault true;
      persistentKeys = mkDefault true;
      config = mkDefault {
        Peers = [ "tcp://${lite21}:${portss.ygg}" ];
        NodeInfo = { name = "${config.networking.fqdn}"; };
        SessionFirewall = {
          enable = true;
          AllowFromDirect = true;
        };
      };
    };

    networking.firewall.allowedUDPPorts =
      optional config.services.cjdns.enable ports.cjd;
    networking.firewall.allowedTCPPorts =
      optional config.services.yggdrasil.enable ports.ygg;
  };
}
