{ config, pkgs, lib, ... }:
let
  jhubDomain = "jhub.${config.networking.hostName}.someonex.net";
  fqdn = "${config.networking.hostName}.someonex.net";
in
{
  services.nginx.enable = true;

  networking.hosts."127.0.0.1" = [ jhubDomain fqdn ];

  security.acme.defaults.email = "sergei.kozlukov@aalto.fi";
  security.acme.acceptTerms = true;
  security.acme.certs."${fqdn}".extraDomainNames = [
    jhubDomain
  ];
  systemd.services."acme-${fqdn}".enable = false;

  services.nginx.recommendedTlsSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedProxySettings = true;

  services.nginx.virtualHosts.${jhubDomain} = {
    forceSSL = true;
    useACMEHost = fqdn;

    locations."/".proxyPass = "http://${config.services.jhub.host}:${toString config.services.jhub.port}/";
    locations."/".extraConfig = ''
      client_max_body_size 256m;
    '';
    locations."/".proxyWebsockets = true;
    listenAddresses =
      [ "127.0.0.1" ]
      ++ config.networking.wg-quick.interfaces.wg24601.address;
  };
  services.nginx.virtualHosts.${fqdn} = {
    forceSSL = true;
    enableACME = true;
  };
}
