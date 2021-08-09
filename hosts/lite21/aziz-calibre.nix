{ config, pkgs, lib, ... }:

let
  hosts.aziz-thinkpad.wireguard.address = "10.24.60.31";
  calibreLocations = {
    "/calibre" = {
      proxyPass = "http://${hosts.aziz-thinkpad.wireguard.address}:8083";
      extraConfig = ''
        proxy_bind              10.24.60.1;
        proxy_set_header        Host            $host;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Scheme        $scheme;
        proxy_set_header        X-Script-Name   /calibre;  # IMPORTANT: path has NO trailing slash
      '';
    };
  };
in {
  services.nginx.virtualHosts = {
    "5.2.76.123".locations = calibreLocations;
    "someonex.net".locations = calibreLocations;
  };
}
