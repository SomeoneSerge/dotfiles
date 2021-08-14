{ config, pkgs, lib, ... }:

let
  hosts.aziz-thinkpad.wireguard.address = "10.24.60.31";
  calibreLocations = {
    "/calibre" = {
      proxyPass = "http://${hosts.aziz-thinkpad.wireguard.address}:8083";
      extraConfig = ''
        # proxy_bind              10.24.60.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host            $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Scheme        $scheme;
        proxy_set_header X-Script-Name   /calibre;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Ssl on;
        proxy_hide_header 'x-frame-options';
        add_header x-frame-options "allowall";
        proxy_read_timeout 90;
        client_max_body_size 256m;
      '';
    };
  };
in
{
  services.nginx.virtualHosts = {
    "5.2.76.123".locations = calibreLocations;
    "someonex.net".locations = calibreLocations;
  };
}
