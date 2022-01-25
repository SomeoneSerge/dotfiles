{ config, pkgs, lib, ... }:
let
  jhubDomain = "jhub.${config.networking.hostName}.someonex.net";
in
{
  services.nginx.enable = true;

  networking.hosts."127.0.0.1" = [ jhubDomain ];
  services.nginx.virtualHosts.${jhubDomain} = {
    locations."/".proxyPass = "http://${config.services.jhub.host}:${toString config.services.jhub.port}";
    listenAddresses =
      [ "127.0.0.1" ]
      ++ config.networking.wg-quick.interfaces.wg24601.address;
  };
}
